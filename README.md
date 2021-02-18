# yet another MediaWiki in Docker

This repo documents how to get the Semantic MediaWiki extension running in a Docker-based MediaWiki server, and what to do with SMW.

### concept

If MediaWiki is a graph where pages are nodes and hyperlinks are edges, then
SMW is a property graph where nodes (pages = entities) can have properties. 

### getting started with this repo

The Makefile documents the steps of using Docker to create a MediaWiki instance that include Semantic MediaWiki.

The Semantic MediaWiki extension is included in the Dockerfile that is used to host MediaWiki. 

# what to do in SMW

Now that you have Semantic MediaWiki (SMW) running, what can you do with it?

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

Once a page has properties, these properties can be queried (using `ask` or `show`) and the results displayed inline.

`{{#show: Main_Page |limit=1 |?Has x_length  }}`

## an example of SMW

Create a new page with the content

    [[my house]] is in [[my neighborhood]] which is part of [[best city]] and exists in [[this state]]

On the `my house` page http://localhost:8080/index.php/My_house specify the category and a property:

    [[Category:houses]]
    [[Has area::43 m^2]]

Populate the `Category:houses` page with

    is a type of [[Subcategory of::building]]

Also, we need to populate a new property `Has area` as well as a new unit `m^2`.  
Find the `Has area` property by first going to http://localhost:8080/index.php/Special:SpecialPages
and then locating `Has area` on http://localhost:8080/index.php/Special:Properties

On the http://localhost:8080/index.php/Property:Has_area page add

    [[Has type::Quantity]]
    {{units_area}}

and then create a new Template for `units_area` with the content

    [[Corresponds to::1 m^2, meter^2, meters^2]] = <Br>
    [[Corresponds to::10.7639 feet^2]]

Now if you revisit the page http://localhost:8080/index.php/My_house the `43 m^2` should not be a broken hyperlink. 

The RDFS can be exported using http://localhost:8080/index.php/Special:ExportRDF 

    <rdf:RDF>
      <swivt:Subject rdf:about="http://localhost/index.php/Special:URIResolver/My_house">
        <rdf:type rdf:resource="http://localhost/index.php/Special:URIResolver/Category-3AHouses"/>
        <rdfs:label>My house</rdfs:label>
        <property:Has_area rdf:datatype="http://www.w3.org/2001/XMLSchema#double">43</property:Has_area>
        <property:Is_member_of rdf:datatype="http://www.w3.org/2001/XMLSchema#string">my neighborhood</property:Is_member_of>
      </swivt:Subject>
    </rdf:RDF>

For more guidance see https://www.semantic-mediawiki.org/wiki/Help:RDF_export

## queries

In a MW page, add the code to 1) collect all "houses" pages, then create a sortable table that includes columns for area and color

    {{#ask:
     [[Category:Houses]]
    |?Has area
    |?Has color
    }}

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

*Pro-tip*: use SMW's `show` to reference values from pages when populating the infobox

    {{game
      |title=Half-Life
      |date={{#show: Main_Page |?Has start date }}
      |genre=FPS
      |mode=Single-Player}}




# MediaWiki markup

https://en.wikipedia.org/wiki/MediaWiki:Common.css  
https://en.wikipedia.org/wiki/MediaWiki:Common.js

# SMW resources

https://www.semantic-mediawiki.org/wiki/Help:Special_properties
https://www.semantic-mediawiki.org/wiki/Help:Type_Record/Using_a_record
https://www.semantic-mediawiki.org/wiki/Help:Property_chains_and_paths
https://www.semantic-mediawiki.org/wiki/Help:Inferencing

# external resources

OWL to SMW:  
"Generating Semantic Media Wiki Content from Domain Ontologies" by Dominik Filipiak  
http://ceur-ws.org/Vol-1275/swcs2014_submission_5.pdf

## offline installation of SMW
https://github.com/SemanticMediaWiki/IndividualFileRelease  
and
https://www.semantic-mediawiki.org/wiki/Help:Installation/Using_Tarball_(without_shell_access)


