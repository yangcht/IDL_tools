# IDL-tools
Small IDL scripts for (astronomical) visualisation, mostly. 

## `fillspec.pro`
Generating the filled molecular spectral plot, which is created by IDL using:
`plot, x, y psym=10`
See the usage in the pro.

## `noema_time.pro`
Calculating the request time for NOEMA given the frequency, request signal to noise ratio, expected linewidth and integrated flux, spectral resolution

## `radial_power.pro`
Plotting the radial distribution whose centre is the  the brightest pixel in the FITS image, only suitable for single source. 
