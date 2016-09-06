;+
; NAME:
;   noema_time
;
;
; PURPOSE:
;   Calculating the on source and total time needed for requested signal to noise ratio at 
;   NOEMA telescope based on the telescope status described in the 2016 winter IRAM call.
;   	Basic formular (referenceL http://www.iram.fr/GENERAL/calls/w16/NOEMACapabilities.pdf)
;	        rms  = (J_pk * T_sys) / (ita * sqrt(N_ant * (N_ant-1)) * t_on * band) / sqrt(N_pol)
;           t_on = ( (J_pk * T_sys)^2. / (ita^2. * rms^2. * N_ant * (N_ant-1) * band * N_pol)
;  
;           
;   INPUTS: 
;          nu_rest: unit in GHz, the rest frequency of the target line
;         redshift: the redshift of the source
;         int_flux: unit in Jy km/s, the expected velocity-integrated line flux
;        linewidth: unit in km/s, the expected linewidth of the target line
;       resolution: unit in km/s, the spectral resolution for resolving the line 
;					(>= 4 bins is better for Gaussian fitting)
; 			   snr: the request snr for the detection
; 
; 
;   KEYWORDS SWITCHES:
;   ...
;
; 
;   OUTPUTS:
;          results = [nu_obs/1.0e9, band/1.0e6, t_on, t_total]
;		  (explain): [sky frequency of the line in GHz, 
;					  resolution in MHz, 
;					  on source time needed in hour,
;					  total time needed in hour]
; 
;
;   PARAMETERS:
;          print_res: if /print_res is set, then this pro will print the 
;		              calculation results on the screen.
;
;
;   RESTRICTIONS:
;           1. The parameters used for the NOEMA telescope will 
;				change according to each call.
;           2. For the source below del = 20 deg, should increase 
;				the observation time according to the situation.
;
;   EXAMPLES:
;           For an expcted line at rest-frame frequency 800 GHz, in a source at redshift = 3.5,  
;           expected integrated line flux equals 0.9 Jy km/s, expected linewidth = 200 km/s,
;           requested spectral resolution = 50 km/s, requested signal to noise ratio = 5.
;           You could run the code like below:
; 
;			     IDL> noema_time, 800, 3.5, 0.9, 200, 50, 5, results = results, /print_res
;			
;           The results will be output through variable "results". Since "print_res" is selected,
;           the results will be printed out as below:
;
;				"Obs freq = 177.8 GHz, resolution =  88.9 MHz, t_on =  1.3 hours, t_total =  2.1 hours,
;				 (Note that the T_sys only counts for the sources at del > 20 deg)"
;
;
;
;   MODIFICATION HISTORY:
;   	Write, 2016-08-31, Chentao Yang (yangcht@gmail.com)
;
;-



PRO noema_time, nu_rest, redshift, int_flux, linewidth, resolution, snr, results = results, print_res = print_res
	; NOEMA Receiver band name
	band_name   =  ["Band 1", "Band 2", "Band 3", "Band 4"]
	; Jy/K, conversion factor from Kelvin to Jansky
	J_pk        =  [22, 29, 35]
	; Efficiency factor due to atmospheric phase noise
	ita         =  [0.9, 0.85, 0.8]
	; System temperature for source at Del>20 deg
	T_sys       =  [90, 175, 130, 170, 200]
	; Number of antennas
	N_ant       =  [6, 8]
	; Number of polarizations
	N_pol       =  [1, 2]
	
	; convert the unit 
	nu_obs  =  (nu_rest*1.0e9)/(1+redshift)                             ; Hz
	band    =  resolution*nu_obs/3.0e5                                  ; Hz
	rms     =  DOUBLE(int_flux)/linewidth*2.35*0.3989/DOUBLE(snr)       ; Jy
	
	IF band LT 2.0e6 THEN N_a = N_ant[0] ELSE N_a = N_ant[1]
	
	CASE 1 OF
		(nu_obs GE 76.5*1.0e9) AND (nu_obs LT 110*1.0e9): $ 
			t_on = (J_pk[0] * T_sys[0])^2. / (ita[0]^2. * rms^2. * N_a * (N_a-1) * band * N_pol[1]) 
		 (nu_obs GE 110*1.0e9) AND (nu_obs LE 116*1.0e9): $ 
		 	t_on = (J_pk[0] * T_sys[1])^2. / (ita[0]^2. * rms^2. * N_a * (N_a-1) * band * N_pol[1])
		 (nu_obs GE 130*1.0e9) AND (nu_obs LT 150*1.0e9): $                               
		 	t_on = (J_pk[1] * T_sys[2])^2. / (ita[1]^2. * rms^2. * N_a * (N_a-1) * band * N_pol[1])
		 (nu_obs GE 150*1.0e9) AND (nu_obs LE 178*1.0e9): $                               
		 	t_on = (J_pk[1] * T_sys[3])^2. / (ita[1]^2. * rms^2. * N_a * (N_a-1) * band * N_pol[1])
		 (nu_obs GE 202*1.0e9) AND (nu_obs LE 274*1.0e9): $                               
		 	t_on = (J_pk[2] * T_sys[4])^2. / (ita[2]^2. * rms^2. * N_a * (N_a-1) * band * N_pol[1])
		  ELSE: BEGIN
			  PRINT, ' '+string(13B) + string(10B)+'Sky frequency '+$
			  STRING(nu_obs/1.0e9, FORMAT='(f6.1)')+'GHz is not in the NOEMA bands.'+$
			  string(13B) + string(10B)
			  GOTO, end_of_pro
		  END
	 ENDCASE
	 
 	CASE 1 OF
 		(nu_obs GE 76.5*1.0e9) AND (nu_obs LE 116*1.0e9):  band_name_selected = band_name[0]
 		 (nu_obs GE 130*1.0e9) AND (nu_obs LE 178*1.0e9):  band_name_selected = band_name[1]
 		 (nu_obs GE 202*1.0e9) AND (nu_obs LE 274*1.0e9):  band_name_selected = band_name[2]
 	ENDCASE
	 
	 t_on    = t_on/3600.0	 
	 t_total = t_on*1.6
	 
	 
	 results = [nu_obs/1.0e9, band/1.0e6, t_on, t_total]
	 
	 IF t_on GE 0.1 THEN BEGIN 
		textout = ' '+string(13B) + string(10B)+ 'Obs freq ='+STRING(nu_obs/1.0e9, FORMAT='(f7.2)')+$
					' GHz, '+'resolution ='+STRING(band/1.0e6, FORMAT='(f6.1)')+' MHz, '+$
					string(13B) + string(10B)+$
					'Requested rms = ' +STRING(rms*1000.d, FORMAT='(f8.4)')+ ' mJy, '+$
					't_on ='+STRING(t_on, FORMAT='(f5.1)')+' hours, '+$
					't_total ='+STRING(t_total, FORMAT='(f5.1)')+' hours, '+$
					string(13B) + string(10B)+$
					'(Note that the T_sys only counts for the sources at del > 20 deg)'+$
					string(13B) + string(10B)
	ENDIF ELSE BEGIN
		textout = ' '+string(13B) + string(10B)+ 'Obs freq ='+STRING(nu_obs/1.0e9, FORMAT='(f7.2)')+$
					' GHz, '+'resolution ='+STRING(band/1.0e6, FORMAT='(f6.1)')+' MHz, '+ $
					string(13B) + string(10B)+$
					'Requested rms = ' +STRING(rms*1000.d, FORMAT='(f8.4)')+ ' mJy, '+$
					't_on ='+STRING(t_on*60, FORMAT='(f5.2)')+' mins, '+$
					't_total ='+STRING(t_total*60, FORMAT='(f5.2)')+' mins, '+$
					string(13B) + string(10B)+$
					'(Note that the T_sys only counts for the sources at del > 20 deg)'+$
					string(13B) + string(10B)
	ENDELSE
	

	IF keyword_set(print_res) THEN print, textout
	 
	 
end_of_pro: 

END		