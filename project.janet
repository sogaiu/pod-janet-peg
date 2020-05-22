(declare-project
  :name "pod-janet-peg"
  :url "https://github.com/sogaiu/pod-janet-peg"
  :repo "git+https://github.com/sogaiu/pod-janet-peg.git"
  :dependencies [
    "https://github.com/janet-lang/json.git"
    "https://github.com/pyrmont/bencodobi"
  ])

(declare-executable
  :name "pod-janet-peg"
  :entry "pod-janet-peg.janet")
