;+
; NAME:
;   FILLSPEC
;
; PURPOSE:
;   Filling the "histogram" like plot below with solid colors.
;       plot, x, y, PSYM=10
;   
; CALLING SEQUENCE:
;   fillspec, x, y, continuum, psym=pysm, linecolor=linecolor, fillcolor=fillcolor
;
; INPUTS:
;   x, y, continuum. The velocity/frequency/wavelength, flux value and 
;   the continuum value. 
;
; KEYWORD INPUTS:
;   psym      =: Set the plotpsym. For plotting the spectrum, we use 10.
;   linecolor =: Set the spetrum stroke color. 
;   fillcolor =: Set the color that fill the space between flux value
;                and the continuum value.
;
; KEYWORDS SWITCHES:
;   ...
;
; OUTPUTS:
;   ...
;
; EXAMPLES:
;    IDL> x = ...          ; input the velocity/frequency/wavelength array
;    IDL> y = ...          ; input the corresponding flux value array
;    IDL> continuum = ...  ; input the corresponding continuum value (array)
;    IDL> fillspec, x, y, continuum, psym=10, linecolor=220, fillcolor=50
;
; SIDEEFFECT:
;   ...
;
; RESTRICTIONS:
;   (Please check if all the variables are in the same order)
;
; MODIFICATION HISTORY:
;   Write, 2012-04-21, Chentao Yang (yangcht@gmail.com)
;   Only for filling the spectrum after plot the spectrum using 
;   plot and set PSYM as 10.
;   
;   Edited on 2015-01-20, Chentao Yang, 
;   Fix the bug when values beyong YRANGEs are presented. 
;   
;   Edited on 2015-07-17, Chentao Yang, 
;   Fix the bug when the continuum is not a constant value.
;   Fix the bug that this pro may change the variables.
;- 


PRO fillspec, x0, y0, cont0, LINECOLOR=LINECOLOR, psym=psym, FILLCOLOR=FILLCOLOR
loadct=5

x_sort=sort(x0)
x=x0(x_sort)
y=y0(x_sort)
n=n_elements(x)

OPLOT, x, y, COLOR=LINECOLOR, psym=psym
        
; Calculate the additional x-values
xnew = (x(0:n-2) + x(1:n-1)) / 2.0D

; Create array containing all x-values
xx = REBIN(xnew, N_ELEMENTS(xnew)*2, /sample)
xx = [min(x), min(x), xx, max(x),max(x)]

; Create array with the corresponding y-values
yy = REBIN(y, N_ELEMENTS(y)*2, /Sample)

; Check if the continuum is a constant
IF (N_ELEMENTS(cont0) NE 1) THEN BEGIN
	cont=cont0(x_sort)
	yy = [cont[0], yy, cont[n_elements(cont)-1]]
ENDIF ELSE BEGIN
	yy = [cont0, yy, cont0]
ENDELSE

y_mi_indx = where(yy LT !Y.CRANGE[0])
y_ma_indx = where(yy GT !Y.CRANGE[1])
IF (y_mi_indx[0] GT 0) THEN yy[y_mi_indx]=FLTARR(N_ELEMENTS(y_mi_indx))+!Y.CRANGE[0] 
IF (y_ma_indx[0] GT 0) THEN yy[y_ma_indx]=FLTARR(N_ELEMENTS(y_ma_indx))+!Y.CRANGE[1] 



; Fill the histogram plot
POLYFILL, xx, yy, COLOR=FILLCOLOR

; Histogram plot
OPLOT, x, y, COLOR=LINECOLOR, psym=psym

END