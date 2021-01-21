%----------------------------------------------------------------------------

function [wave] = wav_bas(zp,s,time,dt,t0,K,m,mother);
    
	n=length(zp);
    disp(round(K))
  wave = zeros(2*round(K)+1,2*n-1);  % define the wavelet array
	wave = wave + i*wave;  % make it complex

   for k=1:2*K+1
      if s(k) == 0
       	w1 = zeros(1,n);  % define the wavelet array
      else
 			if (strcmp(mother,'MORLET'))  %-----------------------------------  Morlet
        		w1 = sqrt(dt/abs(s(k)))*pi.^(-0.25)*...
      	   	 exp(i*m*((time-t0)/s(k))).*exp(-(((time-t0)/s(k)).^2)/2);

         elseif (strcmp(mother,'CHIRP'))  %--------------------------------  Chirp
            a = 6;
   			w1 = sqrt(dt/abs(s(k)))*pi.^(-0.25)*exp(i*a*(((time-t0)/s(k)).^2)/2).*...
      			exp(i*m*((time-t0)/s(k))).*exp(-(((time-t0)/s(k)).^2)/2);

			elseif (strcmp(mother,'PAUL'))  %--------------------------------  Paul
   			w1 = sqrt(dt/abs(s(k)))*(2.^m*i.^m*factor(m)/sqrt(pi*factor(2*m)))*...
               (1-i.*(time-t0)/s(k)).^(-m-1);
			elseif (strcmp(mother,'WIT'))  %--------------------------------  Wit/Tognola
            a = 6;
            w1 = sqrt(dt/abs(s(k)))*(1./(1+((time-t0)/s(k)).^(2*m))).*...
      			exp(i*a*((time-t0)/s(k)));

			elseif (strcmp(mother,'DOG'))  %--------------------------------  Dog
   			if m==1;
   				w0 = sqrt(dt/abs(s(k)))*(1/sqrt(gamma(m+0.5))*(((time-t0)/s(k))).*...
     				  exp(-((time-t0)/s(k)).^2/2));
   			elseif m==2;
  				 	w0 = sqrt(dt/abs(s(k)))*(1/sqrt(gamma(m+0.5)).*(1-(((time-t0)/s(k)).^2)).*...
 				     exp(-((time-t0)/s(k)).^2/2));
  				elseif m==3;
               w0 = sqrt(dt/abs(s(k)))*(1/sqrt(gamma(m+0.5)).*(3*((time-t0)/s(k))-...
                 (((time-t0)/s(k)).^3)).*exp(-((time-t0)/s(k)).^2/2));
            end
            
            if s(k) < 0

   				w2 = hilbert(w0); 
            	w1 = imag(w2)+i*real(w2);
            elseif s(k) > 0
               w1 = hilbert(w0);
            end   
         end

      end
      wave(k,:)=conv(zp,w1);
   end

return


