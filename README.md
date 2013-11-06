Panda Markdown Language [![Build Status](https://travis-ci.org/necrophonic/panda-markdown.png?branch=master)](https://travis-ci.org/necrophonic/panda-markdown)
=======================

A markdown type language and processor for blog postings.

## Vision ##

To develop a simple markdown language that will facilitate easy creation of rich blog postings beyond the scope of vanilla markdown.

### Markdown ###

Simple markdown implemented so far. Maps to standard HTML tags.

```
  - ** - strong
  - // - emphasis
  - __ - underline
  - "" - quote
  - ## - head 1
  - ### - head 2
  - #### - head 3
  - ##### - head 4
  - ###### - head 5
  - ####### - head 6
  - \n\n - new paragraph
  
  - [[<url>]] - <a href="url">url</a>
  - [[<url>|<text>]] - <a href="url">text</a>
  
  - {{/assets/image.jpg}} - <img src="/assets/image.jpg">
```
