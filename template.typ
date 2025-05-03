// font.typ: 字体，字号信息
#import "template/font.typ" : *

// title_page.typ: 标题页面
#import "template/title_page.typ": *

// check_sheet.typ: 打分表
#import "template/check_sheet.typ": *

// cliam.typ: 版权声明
#import "template/claim.typ": *

// abstract.typ : 摘要
#import "template/abstract.typ": *

// content.typ: 目录
#import "template/outline.typ" : *

// numbering.typ: 计数部分
#import "template/numbering.typ" : *


#let lengthceil(len, unit: 字号.小四) = calc.ceil(len / unit) * unit
#let rawcounter = counter(figure.where(kind: "code"))
#let imagecounter = counter(figure.where(kind: image))
#let tablecounter = counter(figure.where(kind: table))
#let equationcounter = counter(math.equation)

// 文档的状态参数
#let doc_mode = state("doc_mode", false)


#let chineseunderline(s, width: 300pt, bold: false) = {
  let chars = s.clusters()
  let n = chars.len()
  context {
    let i = 0
    let now = ""
    let ret = ()

    while i < n {
      let c = chars.at(i)
      let nxt = now + c

      if measure(nxt).width > width or c == "\n" {
        if bold {
          ret.push(strong(now))
        } else {
          ret.push(now)
        }
        ret.push(v(-1em))
        ret.push(line(length: 100%))
        if c == "\n" {
          now = ""
        } else {
          now = c
        }
      } else {
        now = nxt
      }

      i = i + 1
    }

    if now.len() > 0 {
      if bold {
        ret.push(strong(now))
      } else {
        ret.push(now)
      }
      ret.push(v(-0.9em))
      ret.push(line(length: 100%))
    }

    ret.join()
  }
}

#let listoffigures(title: "插图", kind: image) = {
  heading(title, numbering: none, outlined: false)
  context {
    let it = here()
    let elements = query(figure.where(kind: kind).after(it))

    for el in elements {
      let maybe_number = {
        let el_loc = el.location()
        chinesenumbering(counter(heading).at(el_loc).first(), counter(figure.where(kind: kind)).at(el_loc).first(), location: el_loc)
        h(0.5em)
      }
      let line = {
        context {
          let width = measure(maybe_number, styles).width
          box(
            width: lengthceil(width),
            link(el.location(), maybe_number)
          )
        }

        link(el.location(), el.caption.body)

        // Filler dots
        box(width: 1fr, h(10pt) + box(width: 1fr, repeat[.]) + h(10pt))

        // Page number
        let footers = query(selector(<__footer__>).after(el.location()))
        let page_number = if footers == () {
          0
        } else {
          counter(page).at(footers.first().location()).first()
        }
        link(el.location(), str(page_number))
        linebreak()
        v(-0.2em)
      }

      line
    }
  }
}

#let codeblock(raw, caption: none, outline: false) = {
  figure(
    if outline {
      rect(width: 100%)[
        #set align(left)
        #raw
      ]
    } else {
      set align(left)
      raw
    },
    caption: caption, kind: "code", supplement: ""
  )
}

#let booktab(columns: (), aligns: (), width: auto, caption: none, ..cells) = {
  let headers = cells.pos().slice(0, columns.len())
  let contents = cells.pos().slice(columns.len(), cells.pos().len())

  if aligns == () {
    for i in range(0, columns.len()) {
      aligns.push(center)
    }
  }

  let content_aligns = ()
  for i in range(0, contents.len()) {
    content_aligns.push(aligns.at(calc.rem(i, aligns.len())))
  }

  return figure(
    block(
      width: width,
      grid(
        align: center,
        columns: (auto),
        row-gutter: 1em,
        line(length: 100%),
        [
          #set align(center)
          #box(
            width: 100% - 1em,
            grid(
              columns: columns,
              ..headers.zip(aligns).map(it => [
                #set align(it.last())
                #strong(it.first())
              ])
            )
          )
        ],
        line(length: 100%),
        [
          #set align(center)
          #box(
            width: 100% - 1em,
            grid(
              columns: columns,
              row-gutter: 1em,
              ..contents.zip(content_aligns).map(it => [
                #set align(it.last())
                #it.first()
              ])
            )
          )
        ],
        line(length: 100%),
      ),
    ),
    caption: caption,
    kind: table
  );
}

// 标记文档开始的时候的一些状态设置
#let doc_start = () => {
  doc_mode.update(true)
  // 设置文档计数的状态，在numbering.typ文件里
  start_page_counting()
}

// 标记文档结束的时候的一些状态设置
#let doc_end = () => {
  doc_mode.update(false)
  // 设置文档计数的状态，在numbering.typ文件里
  stop_page_counting()
}

#let UndergraduateThesis(
  ctitle: "",
  linespacing: 1em,
  doc,
) = {
  set text(weight: "regular", font: 字体.宋体, size: 字号.小四, lang: "zh")
  
  set heading(numbering: chinesenumbering)
  set list(indent: 2em)
  set enum(indent: 2em)
  
  set page("a4",
    margin: (
      top : 2.5cm,
      right : 2cm,
      left : 2cm,
      bottom : 2.5cm
    ),
    header: context {
      if not doc_mode.at(here()) {
        return
      }
      set align(center)
      set text(font: 字体.宋体, size: 字号.小五, weight: "regular")
      ctitle
      v(-0.5em)
      line(length: 100%)
     },
    footer: foot_numbering(),
  )

  show <reference> : set heading(numbering: none)
  show <thanks> : set heading(numbering: none)
  show strong: it => text(font: 字体.黑体, weight: "semibold", it.body)
  show emph: it => text(font: 字体.楷体, style: "italic", it.body)
  set par(spacing: linespacing)
  show raw: set text(font: 字体.代码)

  show figure: it => [
    #set align(center)
    #if not it.has("kind") {
      it
    } else if it.kind == image {
      it.body
      [
        #set text(字号.五号)
        #it.caption
      ]
    } else if it.kind == table {
      it.body
      [
        #set text(字号.五号) 
        #it.caption
      ]
      
    } else if it.kind == "code" {
      it.body
      [
        #set text(字号.五号)
        代码#it.caption
      ]
    }
  ]
  set math.equation(
    numbering: (..nums) => context {
      set text(font: 字体.宋体)
      numbering("(1.1)", counter(heading).at(here()).first(), ..nums)
    }
  )
  set figure(
    numbering: (..nums) => context {
      set text(font: 字体.宋体)
      numbering("1.1", counter(heading).at(here()).first(), ..nums)
    }
  )

  show heading: it => {
    // Cancel indentation for headings
    set par(first-line-indent: 0em)

    let sizedheading(it, size) = [
      #set text(size : size, font : 字体.黑体)
      #v(0.5em)
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #it.body
      #v(0.4em)
    ]
    set align(left)
    set text(weight: "regular")
    if it.level == 1 {
      sizedheading(it, 字号.三号)
    } else if it.level == 2 {
      sizedheading(it, 字号.小三)
    } else if it.level == 3 {
      sizedheading(it, 字号.四号)
    } else {
      sizedheading(it, 字号.小四)
    }
  }

  show heading.where(depth: 1): body => {    
    pagebreak(weak: true)
    body
  }

  show ref: it => {
    if it.element == none {
      // Keep citations as is
      it
    } else {
      // Remove prefix spacing
      h(0em, weak: true)

      let el = it.element
      let el_loc = el.location()
      if el.func() == math.equation {
        // Handle equations
        link(el_loc, [
          式
          #chinesenumbering(counter(heading).at(el_loc).first(), equationcounter.at(el_loc).first(), location: el_loc, brackets: true)
        ])
      } else if el.func() == figure {
        // Handle figures
        if el.kind == image {
          link(el_loc, [
            图
            #chinesenumbering(counter(heading).at(el_loc).first(), imagecounter.at(el_loc).first(), location: el_loc)
          ])
        } else if el.kind == table {
          link(el_loc, [
            表
            #chinesenumbering(counter(heading).at(el_loc).first(), tablecounter.at(el_loc).first(), location: el_loc)
          ])
        } else if el.kind == "code" {
          link(el_loc, [
            代码
            #chinesenumbering(counter(heading).at(el_loc).first(), rawcounter.at(el_loc).first(), location: el_loc)
          ])
        }
      } else if el.func() == heading {
        // Handle headings
        if el.level == 1 {
          link(el_loc, [
            第
            #chinesenumbering(..counter(heading).at(el_loc), location: el_loc)
            章
          ])
        } else {
          link(el_loc, [
            第
            #chinesenumbering(..counter(heading).at(el_loc), location: el_loc)
            节
          ])
        }
      }
      // Remove suffix spacing
      h(0em, weak: true)
    }
  }


  set par(first-line-indent: (amount: 2em, all: true), leading: 1em)  // https://github.com/typst/typst/pull/5768
  show par : it => context {
    if doc_mode.at(here()) {
      v(0.1em)
      it
    } else {
      it
    }
  }
  
  set align(start)

  // 正文显示部分
  doc
}
