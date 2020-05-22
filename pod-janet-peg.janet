(import bencodobi)
(import json)

# bencode samples
#
#   byte strings
#     0:
#     4:spam
#
#   integers
#     i0e
#     i12e
#     i-8e
#
#   lists
#     le
#     l4:spam4:eggse
#
#   dictionaries (string keys sorted as raw binary)
#     de
#     d3:cow3:moo4:spam4:eggse
#
# via: https://wiki.theory.org/index.php/BitTorrentSpecification#Bencoding

# samples:
#
#   d2:op8:describee
#

## bencode encode

# forward declaration
(var encode nil)

(defn encode-str
  [a-str buf]
  (buffer/format buf
    "%d:%s" (length a-str) a-str))

# XXX: would erroring on non-integer values be better?
(defn encode-int
  [an-int buf]
  (buffer/format buf
    "i%de" (math/trunc an-int)))

(defn encode-list
  [a-list buf]
  (buffer/format buf "l")
  (each elt a-list
    (encode elt buf))
  (buffer/format buf "e"))

(defn encode-dict
  [a-dict buf]
  (buffer/format buf "d")
  # XXX: is this the proper sorting?
  (each k (sort (keys a-dict))
    # XXX: keys should be strings
    (encode-str k buf)
    (encode (in a-dict k) buf))
  (buffer/format buf "e"))

# XXX: this doesn't check input values for sanity
(varfn encode
  [thing buf]
  (case (type thing)
    :number (encode-int thing buf)
    #
    :string (encode-str thing buf)
    :buffer (encode-str (string thing) buf)
    #
    :tuple (encode-list thing buf)
    :array (encode-list thing buf)
    #
    :struct (encode-dict thing buf)
    :table (encode-dict thing buf)
    #
    nil))

## pod protocol

(defn recv
  []
  (def msg
    (bencodobi/decode stdin))
  #
  #(eprintf "%.99j" msg)
  #(eachk k msg
  #  (eprint k ": " (in msg k)))
  #(eflush)
  #
  msg)

(defn send
  [info]
  (def buf @"")
  (encode info buf)
  #
  (prin buf)
  (flush)
  #
  #(eprint "sending: " buf)
  #(eflush)
  #
  buf)

(def describe-response
  {"format" "json"
   "namespaces" [{"name" "pod.janet.peg"
                  "vars" [{"name" "peg-match"}]}]
   "ops" {"shutdown" {}}})

## main entry point

(defn main
  [& args]
  # XXX: log stderr somewhere else
  #(def logf (file/open "/tmp/pod-janet-peg.log" :a+))
  #(setdyn :err logf)
  #
  (recv)
  #
  (send describe-response)
  #
  (while 1
    (def msg (recv))
    (if (= "invoke" (in msg "op"))
      (let [var (in msg "var")
            args (json/decode (in msg "args"))]
        (def [grammar-str the-str] args)
        # XXX: need to defend against error
        (def grammar (eval-string grammar-str))
        (def res
          (peg/match grammar the-str))
        (send {"id" (in msg "id")
               "value" (json/encode (tuple/slice res))
               "status" ["done"]})
        )
      (send {"id" (in msg "id")
             "value" (json/encode ["not invoke"])
             "status" ["done"]}))))

## test

(comment

(require '[babashka.pods :as pods])
(pods/load-pod "pod-janet-peg")
(require '[pod.janet.peg :as pjp])
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

# [[1 2 "three" {:bee 7, :a 6}]]

)
