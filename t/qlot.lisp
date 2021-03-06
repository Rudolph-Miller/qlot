#|
  This file is a part of qlot project.
  Copyright (c) 2014 Eitaro Fukamachi (e.arrows@gmail.com)
|#

(in-package :cl-user)
(defpackage qlot-test
  (:use :cl
        :qlot
        :prove)
  (:import-from :qlot.install
                :uninstall-all-dists)
  (:import-from :uiop
                :file-exists-p
                :delete-directory-tree
                :subdirectories))
(in-package :qlot-test)

(defparameter *tmp-directory* (asdf:system-relative-pathname :qlot #P"t/tmp/"))
(uiop:delete-directory-tree *tmp-directory* :validate t :if-does-not-exist :ignore)
(ensure-directories-exist *tmp-directory*)

(let ((lock (asdf:system-relative-pathname :qlot #P"t/data/qlfile.lock"))
      (lock2 (asdf:system-relative-pathname :qlot #P"t/data/qlfile2.lock"))
      (lock3 (asdf:system-relative-pathname :qlot #P"t/data/qlfile3.lock")))
  (when (uiop:file-exists-p lock)
    (delete-file lock))
  (when (uiop:file-exists-p lock2)
    (delete-file lock2))
  (when (uiop:file-exists-p lock3)
    (delete-file lock3)))

(plan 6)

(ok (install-quicklisp (merge-pathnames #P"quicklisp/" *tmp-directory*))
    "can install Quicklisp")

(uninstall-all-dists (merge-pathnames #P"quicklisp/" *tmp-directory*))

(is (uiop:subdirectories (merge-pathnames #P"quicklisp/dists/" *tmp-directory*))
    '()
    "can uninstall all dists")

(install (asdf:system-relative-pathname :qlot #P"t/data/qlfile")
         :quicklisp-home (merge-pathnames #P"quicklisp/" *tmp-directory*))

(is (mapcar (lambda (path)
              (car (last (pathname-directory path))))
            (uiop:subdirectories (merge-pathnames #P"quicklisp/dists/" *tmp-directory*)))
    '("cl-dbi"
      "clack"
      "datafly"
      "log4cl"
      "quicklisp"
      "shelly")
    :test #'equal
    "can install dists from qlfile")

(update (asdf:system-relative-pathname :qlot #P"t/data/qlfile2")
        :quicklisp-home (merge-pathnames #P"quicklisp/" *tmp-directory*))

(is (mapcar (lambda (path)
              (car (last (pathname-directory path))))
            (uiop:subdirectories (merge-pathnames #P"quicklisp/dists/" *tmp-directory*)))
    '("datafly"
      "log4cl"
      "quicklisp"
      "shelly")
    :test #'equal
    "can update dists from qlfile")

(update (asdf:system-relative-pathname :qlot #P"t/data/qlfile3")
        :quicklisp-home (merge-pathnames #P"quicklisp/" *tmp-directory*))

(is (mapcar (lambda (path)
              (car (last (pathname-directory path))))
            (uiop:subdirectories (merge-pathnames #P"quicklisp/dists/" *tmp-directory*)))
    '("quicklisp")
    :test #'equal
    "can install dists from qlfile")

(like (alexandria:read-file-into-string (merge-pathnames #P"quicklisp/dists/quicklisp/distinfo.txt" *tmp-directory*))
      "version: 2014-12-17"
      "can install old Quicklisp dist")

(finalize)
