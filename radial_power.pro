;+
; NAME:
;   RADIAL_POWER
;
; PURPOSE:
;   Calculating the radial_power, returning radius and normalized
;   integrated power within the radius. 
;
; CALLING SEQUENCE:
;   PRO radial_power, image, radius, integrated
;
; INPUTS:
;   image:      read image from a FITS file and put it into a variable.
;
; KEYWORD INPUTS:
;   ...
;
; KEYWORDS SWITCHES:
;   ...
; OUTPUTS:
;   radius:     the radius from center to each circle.
;   integrated: the normalized integrated power within the radius.
;
; EXAMPLES:
;    IDL> image =...
;   ;input the image into the variable after read the image from FITS file or other file format.
;    IDL> radial_power, image, radius, integrated 
;   ;this will return the radius, and integrated.
;
; SIDEEFFECT:
;   ...
;
; RESTRICTIONS:
;   This pro is only useful for one peak structure, namely if
;   you want to study two objects with comparable peak flux, 
;   this pro is not available, but you can edit it to make it
;   function well.
;   NEED "wherenan.pro"
;
; MODIFICATION HISTORY:
;   Write, Chentao YANG (yangcht@gmail.com), 2013-02-04 
;
;-
 
PRO radial_power, image, radius, integrated
 
; make NaN values = 0
IF (SIZE(WHERE(FINITE(image,/NAN)), /N_ELEMENTS) GT 1) THEN image[WHERE(FINITE(image,/NAN))]=0
 
; get the index of the maximum point
s           = SIZE(image,/dimensions)
m           = (WHERE(image EQ MAX(image)))[0]
y_max       = m/s[0]
x_max       = m MOD s[0] 
 
image_size  = SIZE(image)
image_xdist = FINDGEN(image_size[1])#TRANSPOSE(FINDGEN(image_size[2])*0+1)
image_ydist = TRANSPOSE(FINDGEN(image_size[2])#TRANSPOSE(FINDGEN(image_size[1])*0+1))
image_xdist = (image_xdist-x_max)^2
image_ydist = (image_ydist-y_max)^2
image_dist  = SQRT(image_xdist+image_ydist)
 
radius      = FINDGEN(SQRT(MIN([MAX(image_xdist), MAX(image_ydist)]))*0.7)
integrated  = radius
FOR i=0, (SIZE(radius, /N_ELEMENTS)-1) DO BEGIN
  integrated[i]  = TOTAL(image[WHERE(image_dist LE radius[i])])
ENDFOR
integrated  = integrated/MAX(integrated)

END