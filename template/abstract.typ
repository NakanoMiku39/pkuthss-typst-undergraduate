#import "font.typ": *
#let abstract_title(title) = {
  pagebreak(to: "odd")
  align(center + top)[
    #set text(font: 字体.黑体, size: 字号.三号)
    #title  
  ]
}

#let Abstract(keywords : [], abstract_name, keywords_title, separator, abstract, enable_line) = {
  page(header: none, footer: none)[
    #set align(top + start)


    // #line(length: 100%)
    // Enable the line if enable_line is true
    #if enable_line {
      line(length: 100%)
    }
    
    #v(2em)

    #strong(abstract_title(abstract_name))

    #set text(font: 字体.宋体, size: 字号.小四)
    #set par(justify: true, first-line-indent: 2em, leading: 1em)

    #abstract

    #v(1em)

    #keywords_title#h(0.5em)#keywords.join([#separator])
  ]
}

#let ChineseAbstract(keywords : [], abstract) = {
  Abstract(keywords : keywords, "摘要", "关键词:", "，", abstract, true)
}

#let EnglishAbstract(keywords : [], abstract) = {
  Abstract(keywords : keywords, "ABSTRACT","KEY WORDS:", ", ", abstract, false)
}
