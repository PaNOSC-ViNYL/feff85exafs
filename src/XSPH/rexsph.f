      subroutine rexsph ( mphase, ipr2, ispec, vixan, xkstep, xkmax,
     1             gamach, rgrd,
     1             nph, lmaxph, potlbl, spinph, iatph, nat, rat, iphat,
     2             ixc, vr0, vi0, ixc0, lreal, rfms2, lfms2, l2lp,
     3             ipol, ispin, le2, angks, ptz, iPl, iGrid,
     4             izstd, ifxc, ipmbse, itdlda, nonlocal, ibasis)

      use json_module
      implicit double precision (a-h, o-z)
      logical :: found
      type(json_file) :: json   !the JSON structure read from the file:
      double precision toss
      integer,dimension(:),allocatable :: intgs
      character*80,dimension(:),allocatable :: strings
      double precision,dimension(:),allocatable :: dbpcs

      include '../HEADERS/const.h'
      include '../HEADERS/dim.h'

cc    geom.dat
        integer  nat, iatph(0:nphx), iphat(natx)
        double precision  rat(3,natx)
cc    global.dat 
c       configuration average
        integer nabs, iphabs
c       global polarization data
        integer  ipol, ispin, le2
        double precision evec(3), xivec(3), spvec(3), elpty,angks,rclabs
        complex*16 ptz(-1:1, -1:1)
cc    mod2.inp
        integer mphase, ipr2, ixc, ixc0, ispec, lreal, lfms2, l2lp, iPl, 
     &       iGrid
        double precision rgrd, gamach, xkstep, xkmax, vixan
        double precision vr0, vi0, spinph(0:nphx)
        real rfms2
        integer lmaxph(0:nphx)
        character*6  potlbl(0:nphx)
        integer izstd, ifxc, ipmbse, itdlda, nonlocal, ibasis

c     Local stuff
      character*512 slog
      character*80 head(nheadx)
      dimension lhead(nheadx)

c     standard formats for string, integers and real numbers
  10  format(a)
  20  format (20i4)
  30  format (6f13.5)


c     Read  geom.dat file
      open (file='geom.dat', unit=3, status='old',iostat=ios)
c       read header from geom.dat
        nhead = nheadx
        call rdhead (3, nhead, head, lhead)
        nat = 0
        nph = 0
        do 40 iph = 0, nphx
  40    iatph(iph) = 0
  50    continue
           nat = nat+1
           if (nat .gt. natx)  then
              write(slog,55) ' nat, natx ', nat, natx
              call wlog(slog)
  55          format(a, 2i10)
              stop 'Bad input'
           endif
           read(3,*,end=60)  idum, (rat(j,nat),j=1,3), iphat(nat), i1b
           if (iphat(nat).gt.nph) nph = iphat(nat)
           if ( iatph(iphat(nat)).eq.0) iatph(iphat(nat)) = nat
        goto 50
  60    continue
        nat = nat-1
      close(3)
cc    global.inp
      open (file='global.dat', unit=3, status='unknown',iostat=ios)
c       configuration average data
        read  (3, 10) slog
        read  (3, 65) nabs, iphabs, rclabs
  65    format ( 2i8, f13.5)
c       global polarization data
        read  (3,10)   slog
        read  (3, 70)  ipol, ispin, le2, elpty, angks
  70    format ( 3i5, 2f12.4)
        read  (3, 10) slog
        do 80 i = 1,3
          read  (3,30) evec(i), xivec(i), spvec(i)
  80    continue
        read  (3, 10) slog
        do 90 i = -1, 1
          read (3,30) a1, b1, a2, b2, a3, b3
          ptz(-1,i)= dcmplx(a1,b1)
          ptz(0,i) = dcmplx(a2,b2)
          ptz(1,i) = dcmplx(a3,b3)
  90    continue
      close(3)
c--json--c     read mod2.inp
c--json--c     Josh - added flag iPl for PLASMON card
c--json--c     Josh - added flag iGrid for user controlled grids.
c--json--      open (file='mod2.inp', unit=3, status='old',iostat=ios)
c--json--        read (3,10)  slog
c--json--        read (3,20)  mphase,ipr2,ixc,ixc0,ispec,lreal,lfms2,nph,l2lp,
c--json--     &       iPl,iGrid
c--json--        read (3,10)  slog
c--json--        read (3,30)  vr0, vi0
c--json--        read (3,10)  slog
c--json--        read (3,20)  (lmaxph(iph),iph=0,nph)
c--json--        read (3,10)  slog
c--json--        read (3,170)  (potlbl(iph),iph=0,nph)
c--json--  170   format (13a6)
c--json--        read (3,10)  slog
c--json--        read (3,30)  rgrd, rfms2, gamach, xkstep, xkmax, vixan
c--json--        read (3,30)  (spinph(iph),iph=0,nph)
c--json--        read (3,20)  izstd, ifxc, ipmbse, itdlda, nonlocal, ibasis
c--json--      close(3)

      call json%load_file('xsph.json')
      if (json_failed()) then   !if there was an error reading the file
         print *, "failed to read xsph.json"
         stop
      else
         call json%get('mphase',   mphase, found)
                   if (.not. found) call bailout('mphase', 'xsph.json')
         call json%get('ipr2',   ipr2, found)
                   if (.not. found) call bailout('ipr2', 'xsph.json')
         call json%get('ixc',   ixc, found)
                   if (.not. found) call bailout('ixc', 'xsph.json')
         call json%get('ixc0',   ixc0, found)
                   if (.not. found) call bailout('ixc0', 'xsph.json')
         call json%get('ispec',   ispec, found)
                   if (.not. found) call bailout('ispec', 'xsph.json')
         call json%get('lreal',   lreal, found)
                   if (.not. found) call bailout('lreal', 'xsph.json')
         call json%get('lfms2',   lfms2, found)
                   if (.not. found) call bailout('lfms2', 'xsph.json')
         call json%get('nph',   nph, found)
                   if (.not. found) call bailout('nph', 'xsph.json')
         call json%get('l2lp',   l2lp, found)
                   if (.not. found) call bailout('l2lp', 'xsph.json')
         call json%get('iPlsmn', iPl, found)
                   if (.not. found) call bailout('iPlsmn', 'xsph.json')
         call json%get('iGrid',   iGrid, found)
                   if (.not. found) call bailout('iGrid', 'xsph.json')

         call json%get('vro',   vr0, found)
                   if (.not. found) call bailout('vr0', 'xsph.json')
         call json%get('vio',   vi0, found)
                   if (.not. found) call bailout('vi0', 'xsph.json')

         call json%get('rgrd',   rgrd, found)
                   if (.not. found) call bailout('rgrd', 'xsph.json')
         call json%get('rfms2',  toss, found)
                   if (.not. found) call bailout('rfms2', 'xsph.json')
         rfms2 = real(toss)
         call json%get('gamach',   gamach, found)
                   if (.not. found) call bailout('gamach', 'xsph.json')
         call json%get('xkstep',   xkstep, found)
                   if (.not. found) call bailout('xkstep', 'xsph.json')
         call json%get('xkmax',   xkmax, found)
                   if (.not. found) call bailout('xkmax', 'xsph.json')
         call json%get('vixan',   vixan, found)
                   if (.not. found) call bailout('vixan', 'xsph.json')

         call json%get('izstd',   izstd, found)
                   if (.not. found) call bailout('izstd')
         call json%get('ifxc',   ifxc, found)
                   if (.not. found) call bailout('ifxc')
         call json%get('ipmbse',   ipmbse, found)
                   if (.not. found) call bailout('ipmbse')
         call json%get('itdlda',   itdlda, found)
                   if (.not. found) call bailout('itdlda')
         call json%get('nonlocal',   nonlocal, found)
                   if (.not. found) call bailout('nonlocal')
         call json%get('ibasis',   ibasis, found)
                   if (.not. found) call bailout('ibasis')

         call json%get('potlbl', strings, found)
                   if (.not. found) call bailout('potlbl', 'xsph.json')
         do 1000 itit = 1, nheadx
            potlbl(itit) = strings(itit)(1:6)
 1000    continue
         call json%get('lmaxph', intgs, found)
                   if (.not. found) call bailout('lmaxph', 'xsph.json')
         do 1010 iph = 0, nphx
            lmaxph(iph) = intgs(iph+1)            
 1010    continue
         call json%get('spinph', dbpcs, found)
                   if (.not. found) call bailout('spinph', 'xsph.json')
         do 1020 iph = 0, nphx
            spinph(iph) = dbpcs(iph+1)            
 1020    continue

      end if

!KJ next section added for ELNES calculations 1-06
      open(3,file='eels.inp',status='old',err=100)
        read(3,*)
        read(3,20,end=100,err=100) melnes
      close(3)
      if(melnes.eq.1.and.mphase.eq.1) then
        call wlog(':INFO : rexsph reduces your polarization tensor to 
     1   the unit matrix, because eels.inp says you are doing ELNES.')
        do i=-1,1
        do j=-1,1
        ptz(i,j)=dcmplx(0,0)
        enddo
          ptz(i,i)=dble(1)/dble(3)
          write(*,*) (ptz(i,j),j=-1,1)
        enddo
      endif
100   continue
c !KJ end of my modifications      



c     transform to code units (bohrs and hartrees - atomic unuts)
      rfms2 = rfms2 / real(bohr)
      vr0   = vr0 / hart
      vi0   = vi0 / hart
      gamach = gamach / hart
      vixan = vixan / hart
      xkstep = xkstep * bohr
      xkmax  = xkmax  * bohr
      do 210 i = 1,3
      do 210 iat = 1, nat
        rat(i,iat) = rat(i,iat) / bohr
 210  continue

      return
      end
