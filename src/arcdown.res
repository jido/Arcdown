open Belt

let backtick = "`"

let source = `
[NOTE]
====
This is how to start a new example
block within this block:

[example]
====
.Nested block<
A small example
====
====

:subs: value&more
== Arcdown Test ->> part 1

[Go to ${backtick}Products page${backtick} on this site](/Products.html)

[Go to _Offers page_ in current path](Offers.html)

[Go to an arbitrary webpage](https://www.github.com)

[#anchor]:
Part 1: This text is selected by the anchor.

[<Go to *Part 1*>](#anchor)

____
Quote text using
underscores
____

====
Example block used to
enclose an example
====

****
Sidebar block used to
expand on a topic or
highlight an idea
****

* First<
multi line
* Second&&
** sublist
** one more
  ... nested numbered list
  ... nested 2
* Third
[list]
. Number one
  Indented text without
  line breaks is added
  to a code block

----
Another way to create
a code block delimited
with "----"

****
This is not a new block
----

[:begin region]:
This text can be included
on its own.
[:end region]:
New block starts after label
`

open Promise

let alpha = "A-Za-z"
let alnum = "0-9" ++ alpha

let getMatches = (regex, someline) =>
  switch regex->Js.Re.exec_(someline) {
  | Some(result) =>
    Js.Re.captures(result)->Array.map(x => Js.Nullable.toOption(x)->(Option.getWithDefault(_, "")))
  | None => []
  }

exception EndOfFile(string)
let lines = "\n"->Js.String.split(source)

let nextLine = lnum =>
  switch lines[lnum] {
  | Some(line) =>
    let trimEnd = %re("/^((\s*[^\s]+)*)\s*$/")
    switch trimEnd->getMatches(line) {
    | [_, line, _] => resolve((line, lnum + 1))
    | _ => resolve(("", lnum + 1))
    }
  | None => reject(EndOfFile("EOF"))
  }

type formats =
  | Html
  | Asciidoc

let outputFormat = Html

let specialCharsStep = text =>
  switch outputFormat {
  | Html =>
    let result = Js.String.replaceByRe(%re("/&/g"), "&amp;", text)
    let result = Js.String.replaceByRe(%re("/</g"), "&lt;", result)
    Js.String.replaceByRe(%re("/>/g"), "&gt;", result)
  | Asciidoc => text
  }

type token =
  | Empty
  | Text(string)
  | IndentedText(string)
  | CodeText(string)
  | Heading(int) // == Heading text
  | Attribute(string) // [attributes]
  | BulletListItem(int) // * List item
  | NumberedListItem(int) // . List item
  | IndentedBulletListItem(int) // * List item
  | IndentedNumberedListItem(int) // . List item
  | Label(string) // [label]:
  | SubstitutionDef(string) // :name: value
  | Hyperlink(string) // [text](address)
  | FreeBlockDelimiter // --
  | CodeBlockDelimiter // ----
  | ExampleBlockDelimiter // ====
  | QuoteBlockDelimiter // ____
  | SidebarBlockDelimiter // ****
  | BlockTitle(string) // .Block title
  | SubstitutionUse(string) // {name}

type lineType =
  | Initial
  | Following
  | Code

let consumeBlockTitle = line => {
  let blockTitleLine = %re("/^\.([^\s].*)$/")
  switch blockTitleLine->getMatches(line) {
  | [_, title] => [BlockTitle(title)]
  | _ => []
  }
}

let consumeHeading = line => {
  let titleLine = %re("/^(=+)\s+([^\s].*)$/")
  switch titleLine->getMatches(line) {
  | [_, signs, title] =>
    let level = signs->String.length
    [Heading(level), Text(title)]
  | _ => []
  }
}

let consumeSubstitution = line => {
  let pattern = `^:([${alpha}][_${alnum}]*(\\.[_${alnum}]+)*):\\s+(.*)\$`
  let substLine = Js.Re.fromString(pattern)
  switch substLine->getMatches(line) {
  | [_, name, _, value] => [SubstitutionDef(name), Text(value)]
  | _ => []
  }
}

let consumeAttribute = line => {
  let attrLine = %re("/^\[\s*([^\[\]]*)\]$/")
  switch attrLine->getMatches(line) {
  | [_, attributes] => [Attribute(attributes)]
  | _ => []
  }
}

let consumeHyperlink = line => {
  let hlinkLine = %re("/\[\s*([^\]]*)\]\(\s*([^\s\)]*)\s*\)/")
  switch hlinkLine->getMatches(line) {
  | [_, text, link] => [Hyperlink(link), Text(text)] // do NOT merge text token with the next
  | _ => []
  }
}

let consumeLabel = line => {
  let labelLine = %re("/^\[\s*([^\]]+)\]:\s*$/")
  switch labelLine->getMatches(line) {
  | [_, label] => [Label(label)]
  | _ => []
  }
}

let consumeBulletListItem = line => {
  let itemLine = %re("/^\s*([*]+)\s+(.*)$/")
  switch itemLine->getMatches(line) {
  | [_, stars, text] =>
    let level = stars->String.length
    switch Js.String.charAt(0, line) {
    | "*" => [BulletListItem(level), Text(text)]
    | _ => [IndentedBulletListItem(level), IndentedText(text)]
    }
  | _ => []
  }
}

let consumeNumberedListItem = line => {
  let itemLine = %re("/^\s*([.]+)\s+(.*)$/")
  switch itemLine->getMatches(line) {
  | [_, dots, text] =>
    let level = dots->String.length
    switch Js.String.charAt(0, line) {
    | "." => [NumberedListItem(level), Text(text)]
    | _ => [IndentedNumberedListItem(level), IndentedText(text)]
    }
  | _ => []
  }
}

let consumeBlockDelimiter = line =>
  switch line {
  | "" => [Empty]
  | "--" => [FreeBlockDelimiter]
  | "----" => [CodeBlockDelimiter]
  | "====" => [ExampleBlockDelimiter]
  | "____" => [QuoteBlockDelimiter]
  | "****" => [SidebarBlockDelimiter]
  | _ => []
  }

let consumeRegularLine = line => {
  let chara = Js.String.charAt(0, line)
  let tok = switch chara {
  | "[" => consumeHyperlink(line)
  | "*" => consumeBulletListItem(line)
  | "." => consumeNumberedListItem(line)
  | " " | "\t" =>
    let tokens = consumeBulletListItem(line)
    if tokens == [] {
      let tokens = consumeNumberedListItem(line)
      if tokens == [] {
        [IndentedText(line)]
      } else {
        tokens
      }
    } else {
      tokens
    }
  | _ => []
  }
  if tok == [] {
    [Text(line)]
  } else {
    tok
  }
}

exception EndOfBlock(array<token>)

let consumeInitialLine = (tok, lnum) =>
  nextLine(lnum)->then(((line, lnum)) => {
    let tokens = consumeBlockDelimiter(line)
    switch tokens {
    | [CodeBlockDelimiter] => resolve((tok->Array.concat(tokens), Code, lnum))
    | [_] => resolve((tok->Array.concat(tokens), Initial, lnum))
    | _ => {
        let chara = Js.String.charAt(0, line)
        switch chara {
        | "." =>
          let tokens = consumeBlockTitle(line)
          switch tokens {
          | [BlockTitle(_title)] => resolve((tok->Array.concat(tokens), Initial, lnum))
          | _ =>
            assert(tokens == [])
            let tokens = consumeRegularLine(line)
            resolve((tok->Array.concat(tokens), Following, lnum))
          }
        | "=" =>
          let tokens = consumeHeading(line)
          if tokens != [] {
            resolve((tok->Array.concat(tokens), Following, lnum))
          } else {
            let tokens = consumeRegularLine(line)
            resolve((tok->Array.concat(tokens), Following, lnum))
          }
        | ":" =>
          let tokens = consumeSubstitution(line)
          switch tokens {
          | [SubstitutionDef(_name), Text(_value)] =>
            //let subs = subs->List.add((name, value))
            resolve((tok->Array.concat(tokens), Initial, lnum))
          | _ =>
            assert(tokens == [])
            resolve((consumeRegularLine(line), Following, lnum))
          }
        | "[" =>
          let tokens = consumeAttribute(line)
          switch tokens {
          | [Attribute(_attributes)] => resolve((tok->Array.concat(tokens), Following, lnum))
          | _ =>
            assert(tokens == [])
            let tokens = consumeLabel(line)
            if tokens != [] {
              resolve((tok->Array.concat(tokens), Initial, lnum))
            } else {
              let tokens = consumeRegularLine(line)
              resolve((tok->Array.concat(tokens), Following, lnum))
            }
          }
        | _ =>
          let tokens = consumeRegularLine(line)
          resolve((tok->Array.concat(tokens), Following, lnum))
        }
      }
    }
  })

let consumeLine = (tok, lnum) =>
  nextLine(lnum)->then(((line, lnum)) => {
    let tokens = consumeBlockDelimiter(line)
    if tokens->Array.length != 0 {
      resolve((tok->Array.concat(tokens), Initial, lnum))
    } else {
      let tokens = consumeAttribute(line)
      switch tokens {
      | [Attribute(_attributes)] => resolve((tok->Array.concat(tokens), Following, lnum))
      | _ =>
        assert(tokens == []) // Appease the compiler
        let tokens = consumeLabel(line)
        switch tokens {
        | [Label(_label)] => resolve((tok->Array.concat(tokens), Initial, lnum))
        | _ =>
          assert(tokens == []) // Appease the compiler
          let tokens = consumeRegularLine(line)
          resolve((tok->Array.concat(tokens), Following, lnum))
        }
      }
    }
  })

let consumeCodeLine = (tok, lnum) =>
  nextLine(lnum)->then(((line, lnum)) => {
    if line == "----" {
      resolve((tok->Array.concat([CodeBlockDelimiter]), Initial, lnum))
    } else {
      resolve((tok->Array.concat([CodeText(line)]), Code, lnum))
    }
  })

let parseAttribute = atext => {
  let pattern = `^\\s*([.]?[${alpha}]([.]?[${alnum}])*)`
  let attrExpr = Js.Re.fromString(pattern)
  switch attrExpr->getMatches(atext) {
  | [_, name, _] => Js.log2("Parse: attribute", name)
  | k => Js.log2("Failed to parse:", k)
  }
}

let parseLabel = atext => {
  let pattern = `^\\s*([:#^>]?[${alpha}]([${alnum}])*)`
  let labelExpr = Js.Re.fromString(pattern)
  switch labelExpr->getMatches(atext) {
  | [_, name, _] => Js.log2("Parse: label", name)
  | k => Js.log2("Failed to parse:", k)
  }
}

let parseDocument = tok => {
  let _attributes = HashMap.String.make(~hintSize=10)
  let _substitutions = HashMap.String.make(~hintSize=30)
  tok->Array.forEach(token =>
    switch token {
    | Attribute(attributes) => parseAttribute(attributes)
    | Label(label) => parseLabel(label)
    | _ =>
      // do nothing
      assert(true)
    }
  )
}

let subs = list{}
let attrs = ""
let lnum = 0

exception Success(array<token>)

let rec promi = ((tok, ltype, lnum)) =>
  switch ltype {
  | Initial => consumeInitialLine(tok, lnum)
  | Following => consumeLine(tok, lnum)
  | Code => consumeCodeLine(tok, lnum)
  }
  ->then(promi)
  ->catch(err =>
    switch err {
    | EndOfFile(_) =>
      tok->Array.forEach(token => Js.log2("T: ", token))
      Js.log(`DONE ${tok->Array.length->string_of_int}`)
      tok->parseDocument
      resolve()
    | _ =>
      Js.log("Unexpected error")
      resolve()
    }
  )
promi(([], Initial, lnum))->ignore