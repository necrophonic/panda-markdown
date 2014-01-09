Caffeinated Markup Language
=======================

[![Build Status](https://travis-ci.org/necrophonic/text-caffeinatedmarkup.png?branch=master)](https://travis-ci.org/necrophonic/text-caffeinatedmarkup)

**Current Version 0.12**

The Caffeinated Markup Langauge is an attempt to create a simple yet rich markup language. It was originally created for blog postings on the [Caffeinated Panda Creations website](http://www.caffeinatedpandacreations.co.uk)

Although originally designed to translate to HTML, it has been structured such that it is as agnostic as possible to its output format.

See the wiki for work in progress spec: [Caffeinated Markup Wiki](https://github.com/necrophonic/text-caffeinatedmarkup/wiki)

Examples
========

For purposes of example, the output format is HTML and carriage returns are arbitrary for readability.

Input:
```text
A **wise** --man-- person once said, ""The quick brown //foo// jumps over the
lazy //bar//|A.N.Other""
```

Output:
```text
<p>A <strong>wise</strong> <del>man</del> person once said,</p>
<blockquote>The quick brown <em>foo</em> jumps over the lazy <em>bar</em>
<cite>A.N.Other</cite>
</blockquote>
```

Which might look like:
<p>A <strong>wise</strong> <del>man</del> person once said,</p>
<blockquote>The quick brown <em>foo</em> jumps over the lazy <em>bar</em>
<cite>A.N.Other</cite>
</blockquote>
