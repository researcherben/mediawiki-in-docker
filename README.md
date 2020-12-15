# yet another MediaWiki in Docker

This repo documents how to get Semantic MediaWiki in Docker.

For offline installation of SMW, see
https://github.com/SemanticMediaWiki/IndividualFileRelease
and
https://www.semantic-mediawiki.org/wiki/Help:Installation/Using_Tarball_(without_shell_access)

# CSS and JS

https://en.wikipedia.org/wiki/MediaWiki:Common.css
https://en.wikipedia.org/wiki/MediaWiki:Common.js

# what to do in SMW

## use properties
1. create content on a page that has a property, e.g., `[[Has capital::Berlin]]`
1. find the associated property page using http://localhost:8080/index.php/Special:Properties
1. on the associated property page (e.g., http://localhost:8080/index.php/Property:Has_capital ) add `[[Has type::Page]]`

what about numeric values?
1. create content on a page that has a numeric property, e.g., `[[Has cats::43]]`
1. find the associated property page using http://localhost:8080/index.php/Special:Properties
1. on the associated property page (e.g., http://localhost:8080/index.php/Property:Has_cats ) add `[[Has type::Number]]`

what about numeric values with units?
1. create content on a page that has a numeric property, e.g., `[[Has x_length::43 meters]]`
1. find the associated property page using http://localhost:8080/index.php/Special:Properties
1. on the associated property page (e.g., http://localhost:8080/index.php/Property:Has_x_length ) add 
    
    [[Has type::Quantity]]
    [[Corresponds to::1 m, meter, meters]] = 
    [[Corresponds to::3.28084 ft, feet]] = 
    [[Corresponds to::39.3701 in, inches]]

what if the same dimensions are used on multiple properties?

1. create a new template like http://localhost:8080/index.php/Template:length_units
1. add the above "corresponds to" entries to the new template page.
1. edit the associated property pages to use the template by inserting `{{Length_units}}`

what about temperatures?

1. create content on a page that has a temperature value, e.g., `[[Has temperature::22 Celsius]]`
1. find the associated property page using http://localhost:8080/index.php/Special:Properties
1. on the associated property page (e.g., http://localhost:8080/index.php/Property:Has_temperature ) add `[[Has type::Temperature]]`

## use queries

`{{#show: Main_Page |limit=1 |?Has x_length  }}`

# infobox

## ignore  
https://trog.qgl.org/20140923/setting-up-infobox-templates-in-mediawiki-v1-23/

Scribunto "comes with MediaWiki 1.34 and above. Thus you do not have to download it again."  
source: https://www.mediawiki.org/wiki/Extension:Scribunto

More advanced than I need, but potentially useful in the future:  
https://www.wikidata.org/wiki/Wikidata:Infobox_Tutorial

## works

As per https://stackoverflow.com/a/27801849/1164295 , 
"Infoboxes are just tables with a right side float and some additional formatting."

    {| style="float:right;border:1px solid black"
    | My fantastic infobox
    |-
    | More info
    |}

### just a table
create a new template, e.g., http://localhost:8080/index.php/Template:Game

    {| class="wikitable"
    ! colspan="2" style="text-align: center;" | {{{title}}}
    |-
    | date
    | {{{date}}}
    |-
    | genre
    | {{{genre}}}
    |-
    | mode
    | {{{mode}}}
    |}

Then, on the page where the infobox is desired,

    {{game
      |title=Half-Life
      |date=2004-06-01
      |genre=FPS
      |mode=Single-Player}}

### fancy CSS formatting

From https://www.reddit.com/r/mediawiki/comments/8ypha3/decent_infobox_tutorial/

create a new template, e.g., http://localhost:8080/index.php/Template:FunGame

    {| class="myinfobox"
    ! colspan="2" style="text-align: center;" | {{{title}}}
    |-
    | date
    | {{{date}}}
    |-
    | genre
    | {{{genre}}}
    |-
    | mode
    | {{{mode}}}
    |}

This creates an HTML `<table class="myinfobox">` which can then be styled using CSS

Edit the page http://localhost:8080/index.php/MediaWiki:Common.css with

.myinfobox {
background-color: #ffff00;
border: 2px solid #008600;
float: right;
margin: 0 0 1em 1em;
padding: 1em;
width: 400px;
}     

Pro-tip: use SMW's show to reference values from pages when populating the infobox


