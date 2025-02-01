(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("48042425e84cd92184837e01d0b4fe9f912d875c43021c3bcb7eeb51f1be5710" default))
 '(org-agenda-files '("~/school/school.org"))
 '(org-format-latex-options
   '(:foreground default :background default :scale 1.5 :html-foreground "Black" :html-background "Transparent" :html-scale 1.0 :matchers
     ("begin" "$1" "$" "$$" "\\(" "\\[")))
 '(org-preview-latex-default-process 'dvisvgm)
 '(org-preview-latex-process-alist
   '((dvipng :programs
      ("latex" "dvipng")
      :description "dvi > png" :message "you need to install the programs: latex and dvipng." :image-input-type "dvi" :image-output-type "png" :image-size-adjust
      (2.0 . 2.0)
      :latex-compiler
      ("latex -interaction nonstopmode -output-directory %o %f")
      :image-converter
      ("dvipng -D %D -T tight -o %O %f")
      :transparent-image-converter
      ("dvipng -D %D -T tight -bg Transparent -o %O %f"))
     (dvisvgm :programs
      ("latex" "dvisvgm")
      :description "dvi > svg" :message "you need to install the programs: latex and dvisvgm." :image-input-type "dvi" :image-output-type "svg" :image-size-adjust
      (1.5 . 1.5)
      :latex-compiler
      ("latex -interaction nonstopmode -output-directory %o %f")
      :image-converter
      ("dvisvgm %f --no-fonts --exact-bbox --scale=%S --output=%O --bbox=preview"))
     (imagemagick :programs
      ("latex" "convert")
      :description "pdf > png" :message "you need to install the programs: latex and imagemagick." :image-input-type "pdf" :image-output-type "png" :image-size-adjust
      (2.0 . 2.0)
      :latex-compiler
      ("pdflatex -interaction nonstopmode -output-directory %o %f")
      :image-converter
      ("convert -density %D -trim -antialias %f -quality 100 %O"))))
 '(org-yank-image-save-method "~/school/org/images/")
 '(package-selected-packages '(org-download emacsql))
 '(tab-width 2))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'customize-variable 'disabled nil)
