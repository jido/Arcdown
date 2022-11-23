![logo](Arcdown%20logo.png)
# Arcdown

A lightweight markup language to format documents using plain text

## Syntax

The syntax of Arcdown is heavily inspired by AsciiDoc and by Markdown.

### Headers

```
= Document Title

== Level 1 Section Title

=== Level 2 Section Title...
```

Use "=" in front of the header, repeated as needed to increase the level.

There must be only one document title in the document. The document title may be followed immediately by an
optional document header which contains metadata related to the document, such 
as the authors or a marker for the generator to insert a table of contents.

Example:

```IDL
= Document title
:authors: Author Name <author@email.org>
:version: v2.0, 2019-03-22
:toc:
```

### Paragraphs

A sequence of non-empty lines form a paragraph.

To force a line break in the middle of a paragraph, end the line with "+".

Example:

```
This is part of a single
paragraph spread over
multiple lines of text. +
Because of the line break, this goes on a separate line.
```

Paragraphs may be grouped in a free block by enclosing them with "--".

Example:

```
--
This is the first paragraph.

Another paragraph is added
to the block.
--
```

A paragraph must be followed by an empty line or an indented line. If the
paragraph is at the end of a block, then the empty or indented line can
come after the end block marker. In practice, that means it is better to
separate paragraphs with empty lines and always leave an empty line after
a block.

### Text Formatting

```asciidoc
This is *bold*

This is _italic_

This is `monospaced`

This is ^superscript^

This is ~subscript~

This is #highlighted#

This is +_normal text_ (no style)+
```

Styles can be combined. Any style can be used in the middle of a word by 
doubling the format markers, except for superscript and subscript which
don't require doubling.

Example:

```asciidoc
*_Combine bold and italic_*

the "it" is __it__alic

superscri^pt^ for "pt"
```

To enter text which contains format markers, enclose the text with "+" to prevent
the generator from interpreting them.

### Breaks

Horizontal line:

```
'''
```

Page break (not visible in the browser if the output is a HTML document):

```
<<<
```

### Hyperlinks

```markdown
[Go to Products page on this site](/Products.html)

[Go to Offers page in current path](Offers.html)

[Go to an arbitrary webpage](https://www.github.com)

[#anchor]:
Part 1: This text is selected by the anchor.

[Go to Part 1](#anchor)
```

The text inside square brackets becomes a hyperlink which loads the content
specified in the round brackets. If the round brackets are empty and the 
text matches a section title then the link goes to that section.

When the output format allows it, footnotes are also hyperlinks.

Example:

```markdown
There are contractual implications to this statement.[^terms]

[^terms]:
Please refer to our [Terms and Conditions page](TandC.html) for more information.
```

### Inline Content

```markdown
.sample image
![Arcdown logo](Arcdown-logo.png)

The Github mascot: !![image](octocat.jpg)
```

Use "!" in front of a hyperlink to insert an image or a multimedia file.
Double the "!" to make the image in line with the text rather than in a new block.

The hyperlink text will be used as the "alt" label in HTML.

Captions are set using a [Block Title](#block-title).

See also [Include](#include).

### Lists

```IDL
. Number one
. Number two
. Number three

* First bullet
* Second bullet
* Third bullet

Item 1:: First description
Item 2:: Second description
Item 3:: Third description
```

A list that immediately follows an item from another list is automatically 
nested. Leading whitespace has no effect.

Ordered and unordered list markers can be repeated to indicate the level, 
just like [headers](#headers). Additional levels can be used in a 
description list by adding another ":" each time.

However these levels are not enforced so there could be a list level 1 (\*)
nested inside a list level 2 (\*\*). It is good style to match the marker
level with the nesting level of the list.

Example:

```
. This is number one
** It has two bullets
** This is the second bullet
. This is number two
  .. This is a sublist
  .. with three elements
  .. This is the third element

[list]
. The list attribute forces a
new list to start up
```

Use "+" to force a list item on multiple lines. If it is used on an empty 
line, that starts a new paragraph. Note that indented code blocks don't 
require a "+".

### Styled Blocks

Code blocks (monospaced):

```
  Indented text without
  line breaks is added 
  to a code block
  
  Normal text after a code block
  
  A second code block
  starts here

----
Another way to
create a code 
block using "-"
----

  ----
  A delimited code block
  can also be indented.
  
  It allows empty lines
  ----
```

Other blocks:

```
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
```

### Tables

```IDL
|===
| Header 1 \
| Header 2 \
| Header 3

| Row 1 Column 1 | Row 1 Column 2
| Row 1 Column 3

| Row 2 Column 1
2+| Row 2 Merged columns 2, 3
|===
```

All the headers must be on the same line, or "\\" must be used to escape the 
line breaks otherwise the table is generated without a header row. There 
should be an empty line before the second table row and each new row should 
start on a new line.

When the contents of a cell are written on multiple lines then the start of 
next cell must be on a new line. If there is no space between "|" and the 
text then the generator doesn't interpret the contents until another "|" or 
the end of the line.

Other table styles:

```
,===
Header 1,Header 2,Header 3

Row 1 Column 1,Row 1 Column 2,Row 1 Column 3
Row 2 Column 1,Row 2 Column 2,Row 2 Column 3
,===
```

```
:===
Header 1:Header 2:Header 3

Row 1 Column 1:Row 1 Column 2:Row 1 Column 3
Row 2 Column 1:Row 2 Column 2:Row 2 Column 3
:===
```

### Forms

```
[form]
====
[input,value="Default contents"]
Field label

[checkbox,checked]
Description

[options,value="choice 2"]
* choice 1
* choice 2
* choice 3

[picker]
.Picker label
Any valid Arcdown content
====
```

A form layout has two columns, one for labels and one for form elements.
An input field label or a picker label appears in the first column while
a checkbox description or text for an option appears in the second column.

All form elements can have a value. If an element also has an id, then a
substitution is defined from the id of the element to its value. In case
of a checkbox, the substitution is only defined when the checkbox is 
checked.

### Tabs

```
[tabset]
--
[options,id="maintab"]
* Products
* Portfolio
* Contact

[tab,on="{maintab}::Products"]
****
This is the products tab
****

[tab,on="{maintab}::Portfolio"]
****
This is the portfolio tab
****

[tab,on="{maintab}::Contact"]
****
This is the contact tab
****
--
```

The list of tabs must be in an options form element. The values in the tab list
cannot contain spaces. A numbered list can be used instead of a bullet 
list to select the tab by a number, or a description list to select it by
a term.

If a block title is defined for a tab then that replaces the item in the 
options list for the tab title.

When the output format allows user interaction then the chosen tab is
displayed and other tabs display only their titles. Tabset content that
is not a tab is not displayed.

In other cases, the generator outputs all the tabs in the tab list as
well as tabset content except for the tab list. That allows page breaks.

### Block Title

```markdown
.Fruit basket
,===
apples,oranges,pears
,===

.A mountain sunset on [Flickr](https://www.flickr.com/photos/javh/5448336655)
[size=200x100]
![Sunset](sunset.jpg)
```

A block title starts with a dot "." on its own line. It comes before the
attributes.

If the block title is used with an image, it is used as caption. 
Additionally, if the image caption contains a link then clicking on the 
image loads the (first) link.

### Escape character

The backslash "\\" is used to prevent the generator from interpreting the
following character specially.

Example:

```
\* not a bullet list!
```

See also [Text Formatting](#text-formatting) to prevent format markers from
being interpreted over a span of text using "+".

### Substitutions

```IDL
:substitution: value to be inserted
```

Once defined, substitution values can be reused anywhere.

Example:

```markdown
Using the {substitution}

[{substitution}](/index.html)
```

### Attributes

An attribute is written inside square brackets and applies to the following paragraph or block.

Additional attributes can be applied using commas to separate them.

Example:

```XML
[source,xml]
<root>
  <element>
    This is XML text which 
    can be colourized
  </element>

[NOTE]
====
This is important.
====
```

If the attribute starts with a dot "." and a stylesheet is defined, the specified style class is applied.

Some attributes, such as the style class attribute, can be used in the middle of text by highlighting the part of the text they apply to.

Example:

```
This paragraph contains [.underline]#underlined
text inside#.
```

### Include

```markdown
[include]
[region](Shared-file.arcd)
```

Use the "include" attribute to substitute the hyperlink with the contents 
of an Arcdown file found at the specified location.

The hyperlink text may be used to provide a tag name so only the designated 
region of the Arcdown file is inserted instead of the whole contents.

Note that for security reasons, including a file from an arbitrary location 
is disabled by default.

### Tags

The begin and end tags define a named region for include:

```C
[:begin region]:
This text can be included
on its own

[:end region]:

----
Inside a code block, a named region is
  //-- begin::coderegion ----
defined using begin:: and end:: tags after 
hyphens and before a code block marker 
that ends the line.
  //-- end::coderegion ----
----
```

### Callouts

```Eiffel
[source,ruby]
----
require 'sinatra'
# :1 ----

get '/hi' do 
  # :2 ----
  "Hello World!"
  # :3 ----
end
----
(1):: Library import
(2):: URL mapping
(3):: HTTP response body
```

When it encounters callouts in a code block, the generator inserts 
the callout symbols in the line above and the entire line which 
contains callouts is deleted.

If the deleted line starts with a known block comment marker, the 
generator looks for a matched closing comment marker at the 
beginning of next line and deletes that too. (like `/*` `*/` in C
or `<!--` `-->` in XML)

### Comments

```
// Line comment

////
Comment 
block
////
```

Comments are for information only.

### Localisation

Arcdown documents can be localised for an international audience.

Define the "translations" substitution to enable it:

```
:translations: cn en es fr jp kr ru
```

This tells the generator to look for translations in the listed
directories.

Localisation files contain the text to translate with
synchronisation marks `@` which serve as placeholders for
untranslatable text. These marks always appear at the start of 
a line.

The following are included in the translation:

* formatting
* in-line attributes
* hyperlinks and inline content
* labels (footnotes and anchors)
* callouts
* user-defined substitutions
* comments

By default, code blocks are excluded. To include a code block
use the "localize" attribute:

```c
[localize=Y]
----
This will be translated.
----

----
Use a localize:: tag inside a
code block to select n lines
//-- localize::Y-2 ----
above the tag to translate
----
```

Conversely, the attribute can be used to prevent the translation 
of text:

```
[localize=N]
This must not be translated.
```

If applied to an include, it prevents the generator from looking
for a matching localisation file. Instead, the include link is
added to the translation so that it can be customised for each 
locale.

### Transformation Steps

The generator applies the following steps in order to transform the
contents of the document:

> _localize_ - apply translations to the text (if enabled)
> 
> _specialchars_ - replace special characters with their corresponding 
> entities (`<`, `>` and `&` for HTML). In code blocks, this step also 
> enables syntax highlighting
> 
> _callouts_ - process callouts and code tags
> 
> _format_ - apply inline text formatting
> 
> _substitute_ - replace references with substitution values
> 
> _symbols_ - replace sequences of characters with symbols, for example 
> replace `->` with →
> 
> _apply_ - apply the attributes on blocks and on inline text
> 
> _linebreaks_ - process the line break character `+`

The current style class controls which transformation steps are 
applied. For example, code blocks use the ".verbatim" style class 
which only does the _specialchars_ and _callouts_ transformations.

To choose which steps are applied for a particular style class, define
a special substitution called "steps" followed by the style class.

Example:

```IDL
:steps.formatted: substitute,format,symbols
```
