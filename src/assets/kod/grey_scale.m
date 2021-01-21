
clc
disp('     *********************Directional************************      ')
disp('     *********** Complex Wavelet and complex FFT ************      ')
disp('     *************  For Quadrature data         *************      ')
disp('     ********************* Version 1.0 **********************      ')
disp('     ********************* Dr N AYDIN ***********************      ')
disp('     ********************************************************      ')

nf=0;
 
while nf==0
   
   %*************opens and reads ascii, ms-wav or matlab files *********
   
   switch input('\n Load <A>scii,  ms<W>av,  <M>at(lab) data file:','s');
		case 'a',
      	filtip=0;
      	dir *.asc;  
   	case 'w',
      	filtip=1;
      	dir *.wav;  
   	case 'm',
      	filtip=2;
      	dir *.mat;  
	end
	fid=0;
	while fid < 1
   	if filtip == 2
   		dosya1=input('\n  enter forward signal file name (ef*.mat/af*.mat)(including extension) : ', 's'  );
   		[fid,message] = fopen(dosya1, 'r');
   		if fid == -1
         	disp('\n Cannot open file. Existence? Permission? Memory?...')
      	end   
     		if fid >= 1
      		dosya2=input('\n  enter reverse signal file name (er*.mat/ar*.mat)(including extension) : ', 's'  );
   			[fid,message] = fopen(dosya2, 'r');
   	 		if fid == -1
         		disp('\n Cannot open file. Existence? Permission? Memory?...')
       		end 
	  		end
    	else 
   		dosyadi=input('\n  enter the file name (including extension) : ', 's'  );
   		[fid,message] = fopen(dosyadi, 'r');
   		if fid == -1
      		disp('\n Cannot open file. Existence? Permission? Memory?...')
   		end
   	end
 	end
	clc

%*******reads data into************************

	NS=0;           %default number of samples(all)
	NS=input('now, enter # of samples (0 for all) : ');	%total number of samples
	clc
	disp('........WAIT....READING THE DATA..........')
	if filtip == 1
		fclose(fid);
   	if NS == 0 							
   		[x,Fs,Bits]=audioread(dosyadi);						%read all data of wav file
		else  
      	[x,Fs,Bits]=audioread(dosyadi,NS);					%read NS samples of wav file
   	end
	elseif filtip == 0
		if NS == 0 							
      	x=fscanf(fid,'%f %f',[2 inf]);
   	else  
      	x=fscanf(fid,'%f %f',[2 NS]);
   	end
   	x=x';
   	Fs=7150;
		fclose(fid);
	elseif filtip == 2
   	load(dosya1)
   	load(dosya2)
   	Fs=7150;
   	fclose('all');
   	if NS == 0
      	zi=zf; zg=zr;
   		NS=length(zf);
   	else
      	zi=zf(1:NS); zg=zr(1:NS);
   	end
      zi=zi-mean(zi); zg=zg-mean(zg);
  		zih=hilbert(zi);  
 		zgh=hilbert(zg);
 		z=0.5*(real(zih)-imag(zgh))'+i*0.5*(real(zgh)-imag(zih))'; 
	end
	clc 
	if filtip ~= 2
		siz=size(x);
		NS=siz(1,1);										%find the length of data (NS)							
		z=x(1:NS,2)+x(1:NS,1)*i;						%convert dual channel data to complex data form
%** This section finds directional signals by applying Hilbert transform

		disp('........NOW DECODING QUADRATURE SIGNAL..........')
  		zrh=hilbert(real(z));  
 		zih=hilbert(imag(z));
 		zi=(real(zrh)+imag(zih))';
      zg=(real(zih)+imag(zrh))'; 
      zi=zi-mean(zi); zg=zg-mean(zg);

 	end  
    
   zm=max(max(zi),max(zg));
	zi=zi/zm; zg=zg/zm;
   clear zrh; clear zih; clear n;
   clc
   figure(1);
   clf
   subplot(2,1,1); plot(0:NS-1,zi,'r',0:NS-1,zg,'b'), axis tight; 
	disp('........HIT ANY KEY TO CARRY ON..........')
	pause

%*******************this section is for further analysis such as fft, wavelet etc.*********
	clc

	fprintf('\n data length is: %d \n',NS);
   
   NP=input('\n enter processing frame size: ');		%number of samples per frame
   m=input('\n enter fft size (4for16, 5for32, 6for64, 7for128, 8for256,...): ');	%fft length
   N=2.^m;
   OL=N-1;
   mycol=flipud(gray);
   %mycol=jet;
   br=-0.5;
   WN=input('\n enter window length(equal or less than framesize)   : ');	%window length to be used prior to the fft
	while( WN > N )
   	WN=input('\nmaximum window size is framesize. please reenter: ');
   end
   clc
   
   %********* selects a windowing function *******************
   
	fprintf('\n ***choose one of the following windows by hitting related key*** \n');
	fprintf('\n    <B>artlett **b<L>ackman> ** <C>hebyshev ** <K>aiser \n');
	switch input('\n <G>ausian ** ha<M>ming ** ha<N>ning ** <R>ectangular ** <T>riangular: ','s');
			case 'b',
   		window=bartlett(WN);
			case 'l',
   		window=blackman(WN);
			case 'r',
   		window=boxcar(WN);
			case 'c',
   		Rip=input('\n  Input sidelobe ripple value belove mainlobe in dB for chebyshev window : ');
   		window=chebwin(N,Rip);
			case 'g',
   		t=-(WN/2)+1:(WN/2);
			window=(exp((-2*(t.^2)*(pi.^2))/(WN.^2)))';
         clear t;
      	case 'm',
   		window=hamming(WN);
			case 'n',
   		window=hanning(WN);
			case 'k',
            alfa=input('\n  Input sidelobe attenuation in  dB : ');
            if alfa > 50
               beta=0.1102*(alfa-8.7);
            elseif alfa < 21
                  beta=0;
               else
                  beta=0.5842*(alfa-21).^0.4+0.07886*(alfa-21);
              end          
   		window=kaiser(WN,beta);
			case 't',
   		window=triang(WN);
		end
      clc
      
      %*************** determines wavelet transform parameters ************
      
      scl=input('\n enter number of scales for wavelet analysis: ');		%number of scales for WT
      clc
 	  %   	if scl == 8
     %    	scl=9;
     %    end
     % 	if scl == 32
     %    	scl=33;
     %    end
	fprintf('\n ***choose one of the following wavelets*** \n');
			switch input('\n  ** <C>hirplet ** mor<L>et ** d<O>g ** <P>aul ** <W>it/Tognola **: ','s');
				case 'c',
					mother = 'CHIRP'; m = 6;
				case 'l',
					mother = 'MORLET'; m = 6;
				case 'o',
            	mother = 'DOG';
   				m = input('\n enter order (1, 2 or 3): ');	%window length to be used prior to the fft
						while((m>3 )|(m<1))
   						m = input('\n m cannot be >3 & <1. please reenter: ');
   					end
				case 'p',
					mother = 'PAUL'; 
   				m = input('\n enter order (>0): ');	%window length to be used prior to the fft
 				case 'w',
            	mother = 'WIT';
   				m = input('\n enter order (>0)(actual order is 2*m): ');	%window length to be used prior to the fft
        end
         
      %^^^^^^^^^^^^^^^
	      k=1; nof=1;
			fo=1;											%offset for data segmentation (frame offset)
         t=0:NS-1;
         tim_ax=0:1000/Fs:(1000*(NP-1))/Fs;
   		M=fix(NS./NP);								%number of frames	
   		enbef=0;
    		Fn=Fs/2;
  			clc

%****take fft and WT and calculate sonogram and scalogram***
while enbef == 0
   while nof <= M
      
      %******plots directional signals (originals and processed frames)
      
   	fprintf('\n  frame number: %d',nof);
      if enbef == 0
      	zf=zi(k:(k+NP-1));
         zr=zg(k:(k+NP-1));
         zf=zf/max(max(zf),max(zr));
         zr=zr/max(max(zf),max(zr));
         zp=z(k:(k+NP-1))';
         zp=zp/max(zp);
         
         figure(1);
         subplot(3,1,1); plot(t,zi,'r',t,zg,'b'), axis tight; 
         hold on; 
         subplot(3,1,1); plot(t(k:(k+NP-1)),zi(k:(k+NP-1)),'g',t(k:(k+NP-1)),zg(k:(k+NP-1)),'y');
			hold off;  
         subplot(3,1,2); plot(tim_ax,real(zp(1:NP)),'r',tim_ax,imag(zp(1:NP)),'b'), axis tight;  
         subplot(3,1,3); plot(tim_ax,zf,'r',tim_ax,zr,'b'), axis tight;  
      end
      
      %****take fft and WT********
      %++++++++++++++++++++++++++++
      h=[zeros(fix((N-WN)/2),1); window; zeros(ceil((N-WN)/2),1)];
		zp1=[zeros(1,fix(OL/2)), zp, zeros(1,ceil(OL/2))];
		for nc=1:NP
   		for nr=1:N
     		 	zp2(nr,nc)=zp1(nc+nr-1).*h(nr);
   		end
		end
      
      %*****fft*********
      tic
      zf1=(fft(zp2))./N;
      zft=abs(zf1);
      zfr=[zft((N/2)+1:N,:); zft(1:N/2,:)].^2;
      ftim=toc;
      zfra=angle(zf1);
      zfr=zfr/max(max(zfr));
      f1=[((-N/2)+1:(N/2))*Fs/N];

      %++++++++++++++++++++++++++++

		figure(2); clf;
      subplot(411); plot(tim_ax,real(zp(1:NP)),'r',tim_ax,imag(zp(1:NP)),'b'), axis tight;
%		title('in-phase(—), quadrature-phase(...) flow signals'); 
      xlabel('Time(ms)');
		subplot(412); plot(tim_ax,zf,'r',tim_ax,zr,'b'), axis tight;
%		title('forward(—), reverse(...) flow signals'); 
      xlabel('Time(ms)');
      subplot(413); 
 %     imagesc(zfr,'Xdata',[tim_ax(1) tim_ax(NP)],'Ydata',[f1(1) f1(N)]/1000), axis tight, axis xy; 
      pcolor(tim_ax,f1/1000,zfr), axis tight, axis xy; shading interp; 
      ylabel('Frq(kHz)');  xlabel('Time(ms)');
      colormap(mycol); brighten(mycol,br);
      
      figure(3);
		subplot(311);
      plot(tim_ax,zf,'r',tim_ax,zr,'b'), axis tight;
%		title('forward(—), reverse(...) flow signals'); 
      xlabel('Time(ms)');
		subplot(312);  
 %     meshc(tim_ax,f1,zfr), axis tight;
      surf(tim_ax,f1/1000,zfr), axis tight; shading interp;
      ylabel('Frq(kHz)'); 	
      xlabel('Time(ms)'); 
      colormap(mycol); brighten(mycol,br);
      
	
     
%+++++++++++++++
dt = 1./Fs ;
time = [0:NP-1]*dt;  % construct time array
t0=dt*NP/2;
K=scl+(scl/8);
s0=2*dt;
%dk=0.125;
dk = (log2(NP*dt/s0))/(K-1);

s=s0.*2.^([0:K-1]*dk);
s=[-(fliplr(s)) 0 s];
 
 % Wavelet transform:
 tic
 
[wave] = wav_bas(zp,s,time,dt,t0,round(K),m,mother);
w = wave(round((scl/16)+1:2*scl+(scl/16)+1),round(NP/2:3*NP/2-1));
cs = (abs(w)).^2;        % compute wavelet power spectrum
wtim=toc;
csa= angle(w);
cs=cs/max(max(cs));
%freq=[1./period];	
s1=[-scl:scl];
%+++++++++++++++

   	figure(2);
   	subplot(414);  
 %     imagesc(cs,'Xdata',[tim_ax(1) tim_ax(NP)],'Ydata',[s1(1) s1(2*scl)]), axis tight, axis xy; 
      pcolor(tim_ax,s1,cs), axis tight, axis xy; shading interp; 
      ylabel('Scale');   xlabel('Time(ms)');
      
   	figure(4);
   	subplot(211);
      plot(tim_ax,zf,'r',tim_ax,zr,'b'), axis tight;
%		title('forward(—), reverse(...) flow signals'); 
      xlabel('Time(ms)');
   	subplot(212);
 %  	imagesc(cs,'Xdata',[tim_ax(1) tim_ax(NP)],'Ydata',[s1(1) s1(2*scl)]), axis tight, axis xy; 
      pcolor(tim_ax,s1,cs), axis tight, axis xy; shading interp; 
      ylabel('Scale');  
      xlabel('Time(ms)');
		colormap(mycol); brighten(mycol,br);

      figure(3);
		subplot(313);  
%		meshc(tim_ax,s1,cs), axis tight;     
		surf(tim_ax,s1,cs), axis tight; shading interp;     
      ylabel('Scale');  xlabel('Time(ms)'); 
		colormap(mycol); brighten(mycol,br);
     
      
      
      %^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  %********* this is to calculate instantaneous power (IP) (frequency averaged tf distribution)*******************
    %  zfrs=sum(zfr()./(N);			%average  alongside the frequency on fft results
    %  zfrs=zfrs/max(zfrs);
		zfrt=sum(zfr')./NP;				%average alongside the time on fft results
      zfrt=zfrt/max(zfrt);
      zfrs_r=mean(zfr(1:(N/2)-1,:));
      zfrs_f=mean(zfr((N/2)+1:N,:));
      zfrs_r=zfrs_r/max(max(zfrs_f),max(zfrs_r));
      zfrs_f=zfrs_f/max(max(zfrs_f),max(zfrs_r));
    %  css=sum(cs)./(2*scl);			%average  alongside the frequency on fft results
    %  css=css/max(css);
		cst=sum(cs')./NP;				%average alongside the time on fft results
      cst=cst/max(cst);
      css_r=mean(cs(1:scl,:));
      css_f=mean(cs(scl+2:2*scl+1,:));
      css_r=css_r/max(max(css_f),max(css_r));
      css_f=css_f/max(max(css_f),max(css_r));
      
     
 %//////////////////this section is to apply some statistics to the FT  results/////////////////////////////
 
      
      %**********plot frequncy averaged tfd and single line with max power************************             
     
      figure(5);
      subplot(211);
     	plot(f1/1000,zfrt,'r'), axis tight;
      subplot(212);
     	plot(s1,cst,'r'), axis tight;
     
      
     
      %******** plot for only report purpose ******
      
      figure(6);
		subplot(321);
      plot(tim_ax,real(zp(1:NP)),'r',tim_ax,imag(zp(1:NP)),'b'), axis tight; xlabel('Time(ms)'); 
		subplot(322);
      plot(tim_ax,zf(1:NP),'r',tim_ax,zr(1:NP),'b'), axis tight; xlabel('Time(ms)'); 
      subplot(334); 
 %     imagesc(zfr,'Xdata',[tim_ax(1) tim_ax(NP)],'Ydata',[f1(1) f1(N)]/1000), axis tight, axis xy; 
      pcolor(tim_ax,f1/1000,zfr), axis tight, axis xy; shading interp; 
      ylabel('Frq(kHz)'); xlabel('Time(ms)'); 
		colormap(mycol); brighten(mycol,br);
  		subplot(335);
     	plot(tim_ax,zfrs_f(1:NP),'r',tim_ax,zfrs_r(1:NP),'b'), axis tight; xlabel('Time(ms)');
    	subplot(336);
      plot(f1/1000,zfrt,'r'), axis tight; xlabel('Frq(kHz)'); 
      subplot(337);
   %   imagesc(cs,'Xdata',[tim_ax(1) tim_ax(NP)],'Ydata',[s1(1) s1(2*scl)]), axis tight, axis xy; 
      pcolor(tim_ax,s1,cs), axis tight, axis xy; shading interp; 
      ylabel('Scale'); xlabel('Time(ms)'); 
		colormap(mycol); brighten(mycol,br);
    
      subplot(339);
 		plot(s1,cst,'r'), axis tight; xlabel('Scale');
       
      figure(7);
		subplot(321);
      plot(tim_ax,real(zp(1:NP)),'r',tim_ax,imag(zp(1:NP)),'b'), axis tight; xlabel('Time(ms)'); 
		subplot(322);
      plot(tim_ax,zf(1:NP),'r',tim_ax,zr(1:NP),'b'), axis tight;  xlabel('Time(ms)'); 
      subplot(323); 
 %     imagesc(zfr,'Xdata',[tim_ax(1) tim_ax(NP)],'Ydata',[f1(1) f1(N)]/1000), axis tight, axis xy; 
      pcolor(tim_ax,f1/1000,zfr), axis tight, axis xy; shading interp; 
      ylabel('Frq(kHz)'); xlabel('Time(ms)'); 
		colormap(mycol); brighten(mycol,br);
  		subplot(324);
 %     imagesc(cs,'Xdata',[tim_ax(1) tim_ax(NP)],'Ydata',[s1(1) s1(2*scl)]), axis tight, axis xy; 
      pcolor(tim_ax,s1,cs), axis tight, axis xy; shading interp; 
      ylabel('Scale'); xlabel('Time(ms)'); 
		colormap(mycol); brighten(mycol,br);
    	
      subplot(326);
 %     imagesc(csa,'Xdata',[tim_ax(1) tim_ax(NP)],'Ydata',[s1(1) s1(2*scl)]), axis tight, axis xy; 
      pcolor(tim_ax,s1,csa), axis tight, axis xy; shading interp; 
      ylabel('Scale');  xlabel('Time(ms)');
		colormap(mycol); brighten(mycol,br);
%*********************************************
            
      disp('........HIT ANY KEY TO CARRY ON..........')
      pause
    %^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
 %************* menu for changing parameters and further processing ************************
 
      fprintf('\n\n*<R>ead new file*,*read <M>at/asc/wav files*,*<N>ext/<P>revious frame*,*change<W>avelet*,*new s<C>ale*');
 		switch input('\n*<S>ave frame*,*Shift frame <L> points(+/-)*,*new <F>rame size*,*new w<I>ndow& fft size*,*<T>erminate*:','s');
      	case 'n',
         	if nof==M
            	clc
               fprintf('\n  you are already at the end of the waveform (frame no: %d)',n);
               fprintf('\n ***press any key to carry on*** \n');
               pause
          		enbef=1; nf=0;
               clc
             else 
               clc
               k=k+NP; nof=nof+1; 	enbef=0;
             end
         case 'p',
             if nof==1
               clc
               fprintf('\n  you are already at the beginning of the waveform (frame no: %d)',n);
               fprintf('\n ***press any key to carry on*** \n');
          		enbef=1; nf=0;
               pause
               clc
             else 
             	clc
              	k=k-NP; nof=nof-1; 	enbef=0; nf=0;
             end
         case 'r',
            	clear;
            	enbef=1;
              	nf=0;
              	clc
               break;
         case 's',
               clc
               dir *.mat;
               filef=input('\n enter file name for forward signal (ef*.mat/af*.mat): ', 's'  );
               filer=input('\n enter file name for reverse signal (er*.mat/ar*.mat): ', 's'  );
               clc
               save zf zf; save zr zr;
               copyfile('zf.mat',filef); copyfile('zr.mat',filer);
           		enbef=1; nf=0;
              	clc
         case 'm',
               clc
   				switch input('\n Load <A>scii,  ms<W>av,  <M>at(lab) data file:','s');
						case 'a',
      					dir *.asc;  
                  	if filtip == 0
                     	fprintf('\n current open file is: "%s" \n',dosyadi);
                     end   
                     filtip=0;
   					case 'w',
      					dir *.wav;  
                   	if filtip == 1
                     	fprintf('\n current open file is: "%s" \n',dosyadi);
                     end   
                     filtip=1;
   					case 'm',
      					dir *.mat;  
                  	if filtip == 2
                        fprintf('\n current open files are: "%s" and "%s" \n',dosya1, dosya2);
                     end
      					filtip=2;
					end
					fid=0;
					while fid < 1
                  if filtip == 2
   						dosya1=input('\nenter forward signal file name (*f*.mat): ', 's'  );
   						[fid,message] = fopen(dosya1, 'r');
   						if fid == -1
         					disp('\n Cannot open file. Existence? Permission? Memory?...')
      					end   
     						if fid >= 1
      						dosya2=input('\nenter reverse signal file name (*r*.mat): ', 's'  );
   							[fid,message] = fopen(dosya2, 'r');
   	 						if fid == -1
         						disp('\n Cannot open file. Existence? Permission? Memory?...')
       						end 
	  						end
    					else 
   						dosyadi=input('\nenter the file name (including extension): ', 's'  );
   						[fid,message] = fopen(dosyadi, 'r');
   						if fid == -1
      						disp('\n Cannot open file. Existence? Permission? Memory?...')
   						end
   					end
 					end
					clc

%*******reads data into************************

					disp('........WAIT....READING THE DATA..........')
					if filtip == 1
						fclose(fid);
   					if NS == 0 							
   						[x,Fs,Bits]=audioread(dosyadi);						%read all data of wav file
						else  
      					[x,Fs,Bits]=audioread(dosyadi,NS);					%read NS samples of wav file
   					end
					elseif filtip == 0
						if NS == 0 							
      					x=fscanf(fid,'%f %f',[2 inf]);
   					else  
      					x=fscanf(fid,'%f %f',[2 NS]);
   					end
   					x=x';
   					Fs=7150;
						fclose(fid);
					elseif filtip == 2
   					load(dosya1)
   					load(dosya2)
   					Fs=7150;
   					fclose('all');
   					if NS == 0
      					zi=zf; zg=zr;
   						NS=length(zf);
   					else
      					zi=zf(1:NS); zg=zr(1:NS);
   					end
      				zi=zi-mean(zi); zg=zg-mean(zg);
				  		zih=hilbert(zi); 	zgh=hilbert(zg);
 						z=0.5*(real(zih)-imag(zgh))'+i*0.5*(real(zgh)-imag(zih))'; 
					end
					clc 
					if filtip ~= 2
						siz=size(x);
						NS=siz(1,1);										%find the length of data (NS)							
						z=x(1:NS,2)+x(1:NS,1)*i;						%convert dual channel data to complex data form

%** This section finds directional signals by applying Hilbert transform
						disp('........NOW DECODING QUADRATURE SIGNAL..........')
  						zrh=hilbert(real(z));  
 						zih=hilbert(imag(z));
 						zi=(real(zrh)+imag(zih))';
						zg=(real(zih)+imag(zrh))'; 
 					end  
               clear zrh; clear zih; clear x; 
   		   	zi=zi-mean(zi); zg=zg-mean(zg);
      			zm=max(max(zi),max(zg));
		      	zi=zi/zm; zg=zg/zm;
   				Fn=Fs/2;
					fo=1;											%offset for data segmentation (frame offset)
   				t=0:NS-1;
             	k=1; nof=1;
              	enbef=0; nf=0;
               clc
                 
         case 't',
               enbef=1; nf=1;
               clc
               break;
         case 'l',
               clc
               L=input('enter # of points to shift frame position (+/-#) : ');	%total number of samples
               k=k+L;
               nof=nof+fix(L/NP);
               nf=0; enbef=0;
               clc
         case 'w',
               clc
               fprintf('\n current wavelet is: %s \n',mother);
					fprintf('\n ***choose one of the following wavelets*** \n');
					switch input('\n  ** <C>hirplet ** mor<L>et ** d<O>g ** <P>aul ** <W>it/Tognola **: ','s');
						case 'c',
							mother = 'CHIRP'; m = 6;
						case 'l',
							mother = 'MORLET'; m = 6;
						case 'o',
            			mother = 'DOG';
   						m = input('\n enter order (1, 2 or 3): ');	%window length to be used prior to the fft
								while((m>3 )|(m<1))
   								m = input('\n m cannot be >3 & <1. please reenter: ');
   							end
						case 'p',
							mother = 'PAUL'; 
   						m = input('\n enter order (>0): ');	%window length to be used prior to the fft
 						case 'w',
            			mother = 'WIT';
   						m = input('\n enter order (>0)(actual order is 2*m): ');	%window length to be used prior to the fft
         		end
               enbef=0; nf=0;
               clc
               
          case 'i'
             
             	fprintf('\n current fft size is: %d \n',N);
   				m=input('\n enter new fft size (4for16, 5for32, 6for64, 7for128, 8for256,...): ');	%fft length
   				N=2.^m;
   				OL=N-1;
               
               fprintf('\n current window size is: %d \n',WN);
  					WN=input('\n enter new window length(equal or less than fft framesize)   : ');	%window length to be used prior to the fft
					while( WN > N )
   					WN=input('\nmaximum window size is framesize. please reenter: ');
   				end
   				clc
   				fprintf('\n ***choose one of the following windows by hitting related key*** \n');
					fprintf('\n    <B>artlett **b<L>ackman> ** <C>hebyshev ** <K>aiser \n');
					switch input('\n <G>ausian ** ha<M>ming ** ha<N>ning ** <R>ectangular ** <T>riangular: ','s');
						case 'b',
   						window=bartlett(WN);
						case 'l',
   						window=blackman(WN);
						case 'r',
   						window=boxcar(WN);
						case 'c',
   						Rip=input('\n  Input sidelobe ripple value belove mainlobe in dB for chebyshev window : ');
   						window=chebwin(N,Rip);
						case 'g',
   						tw=-(WN/2)+1:(WN/2);
							window=(exp((-2*(tw.^2)*(pi.^2))/(WN.^2)))';
       				   clear tw;
      				case 'm',
   						window=hamming(WN);
						case 'n',
   						window=hanning(WN);
						case 'k',
           				alfa=input('\n  Input sidelobe attenuation in  dB : ');
            			if alfa > 50
              				 beta=0.1102*(alfa-8.7);
            			elseif alfa < 21
                 			 beta=0;
               		else
                 			 beta=0.5842*(alfa-21).^0.4+0.07886*(alfa-21);
              			end          
   						window=kaiser(WN,beta);
						case 't',
   						window=triang(WN);
					end
      			clc
               
         case 'c',
               clc
               fprintf('\n current scale is: %d \n',scl);
               scl=input('\n enter new number of scales: ');		%number of samples per frame,fft length
 	     		%	if scl == 8
         	%		scl=9;
        		%	end
      		%	if scl == 32
         	%		scl=33;
        		%	end
               enbef=0; nf=0;
      			clc
         case 'f',
               clc
               fprintf('\n data length is: %d \n',NS);
               fprintf('\n current processing frame size is: %d \n',NP);
			      NP=input('\n enter new processing frame size: ');		%number of samples per frame,fft length
               enbef=0; nf=0;
         	   k=1; nof=1;
               M=fix(NS/NP);								%number of frames	
    				clc
      end
      clc      
    end 
  	 clc
  end 
  clc
end
  
