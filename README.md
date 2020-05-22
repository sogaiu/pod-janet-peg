# pod-janet-peg

A [babashka pod](https://github.com/babashka/babashka.pods) for
calling Janet's peg/match function.  Implemented using the
[Janet](https://github.com/janet-lang/janet) programming language.

## Install

* [Install Janet](https://janet-lang.org/docs/index.html)

* Clone the source

  ```
  git clone https://github.com/sogaiu/pod-janet-peg
  ```

* Build

  ```
  cd pod-janet-peg
  jpm deps
  jpm build
  ```

  A `build` subdirectory should exist and an executable named
  `pod-janet-peg` should be contained within.  (On Windows it should
  have the usual file extension).

* Place the resulting binary on your PATH

  I tend to symlink directly to the file in the build directory from
  some directory on my PATH.

## Demo

Run in [babashka](https://github.com/borkdude/babashka/) or using the
[babashka.pods](https://github.com/babashka/babashka.pods) library on the JVM.

``` clojure
;; the usual pod set up
(require '[babashka.pods :as pods])
(pods/load-pod "pod-janet-peg")
(require '[pod.janet.peg :as pjp])

;; ... and now the punchline
(pjp/peg-match
 "~{:main :data
    :data (choice :list :table :number :string)
    :list (group (sequence \"l\" (any :data) \"e\"))
    :table (sequence \"d\" (replace (any (sequence :string :data))
                                  ,struct)
                     \"e\")
    :number (sequence \"i\" :digits \"e\")
    :digits (replace (capture :d+)
                     ,scan-number
                     :digits)
    :string (replace (sequence :digits \":\"
                               (capture (lenprefix (backref :digits) 1)))
                     ,|$1)}"
 "li1ei2e5:threed1:ai6e3:beei7eee")
```

The return value should be:

``` clojure
[[1 2 "three" {:bee 7, :a 6}]]
```

## What Just Happened?

The pod exposes [Janet's PEG functionality](https://janet-lang.org/docs/peg.html).

The code above uses a mostly complete grammar for [Bencoding](https://wiki.theory.org/index.php/BitTorrentSpecification#Bencoding) to parse a bencoded string.

## Thanks

* andrewchambers - libs and more
* bakpakin - Janet
* borkdude - babashka, pods, and more
* leafgarland - bencode grammar
* pyrmont - bencodobi

... and possibly other people I forgot including Janet gitter channel
participants :)
