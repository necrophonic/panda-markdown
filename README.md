Panda Markdown Language [![Build Status](https://travis-ci.org/necrophonic/panda-markdown.png?branch=master)](https://travis-ci.org/necrophonic/panda-markdown)
=======================

A markdown type language and processor for blog postings.

## Vision ##

To develop a simple markdown language that will facilitate easy creation of rich blog postings beyond the scope of vanilla markdown.

### Markdown ###


```
  > **text** - strong text e.g. <strong>text</strong>
  > //text// - emphasised text e.g. <em>text</em>
  > __text__ - underlined text e.g. <u>text</u>
  > ""text"" - quote e.g. <blockquote>text</blockquote>

  > \n\n - new paragraph
  > \n - line break

  > {{image.png|W10,H10,>>}} - local image e.g. <img src="image.png" height="10" width="10" class="right">
  > {{image.png}} - local image with no options e.g. <img src="image.png">

  > [[http://google.com|Google]] - href e.g. <a href="http://google.com">Google</a>
  > [[http://google.com]] - href with no text e.g. <a href="http://google.com">http://google.com</a>

  > ##1|text## - header ( ##<level>|<text>## ) e.g. <header1>text</header1>

  > @@<content>@@ - row
  > ||Col data - column
  e.g.
    @@
     ||Column 1
     ||Column 2
    @@
```
