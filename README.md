# linen.lua


linen is a small plugin to enable multithreading with lurker. simply drop it in your project (somewhere near lurker.lua) and `require("linen")` it!


### Prerequisites
you will need [lurker.lua](github.com/rxi/lurker/ Lurker) and [lume](github.com/rxi/lume Lume) for linen to work



### Setup & Configuration
most of lurker's config options will coninue working as is when you require linen. the only exception to this rule is lurker.interval, which must be changed with linen.setInterval(). this can be run at any time.
