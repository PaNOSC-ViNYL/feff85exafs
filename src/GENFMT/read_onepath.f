      subroutine json_read_onepath(ipol, index, nleg, nsc, deg, rat,
     &        ipot, nnnn_out, json_out, ri, beta, eta)

      use json_module
      implicit double precision (a-h, o-z)

      include '../HEADERS/const.h'
      include '../HEADERS/dim.h'

      logical :: found
      type(json_file) :: json   !the JSON structure read from the file:
      double precision,dimension(:),allocatable :: dbpcs

      integer index, nleg, ipot(0:legtot)
      double precision rat(3,0:legtot+1)
      logical nnnn_out, json_out

      double precision ri(legtot), beta(legtot+1), eta(0:legtot+1)
      complex*16  alph, gamm
      dimension  alpha(0:legtot), gamma(legtot)
      character*5 vname

      call json%load_file('onepath.json')
      if (json_failed()) then   !if there was an error reading the file
         print *, "failed to read onepath.json"
         stop
      else
         call json%get('index', index, found)
             if (.not. found) call bailout('index', 'onepath.json')
         call json%get('nleg',  nleg,  found)
             if (.not. found) call bailout('nleg',  'onepath.json')
         call json%get('deg',   deg,   found)
             if (.not. found) call bailout('deg',  'onepath.json')
         call json%get('nnnn_out', nnnn_out, found)
             if (.not. found) call bailout('nnnn_out', 'onepath.json')
         call json%get('json_out', json_out, found)
             if (.not. found) call bailout('json_out', 'onepath.json')

         do 10 iat=1,nleg
            write (vname, "(A4,I1)") "atom", iat
            call json%get(vname, dbpcs, found)
                 if (.not. found) call bailout(vname, 'onepath.json')
            
c           convert distances to code units
            rat(1,iat)  = dbpcs(1)/bohr
            rat(2,iat)  = dbpcs(2)/bohr
            rat(3,iat)  = dbpcs(3)/bohr
            ipot(iat)   = int(dbpcs(4)+0.5)
 10      continue

         call json%destroy()
      end if


c+---------------------------------------------------------------------
c  the following is cut-n-pasted from rdpath
c  using the coordinates of the path's constituent atoms,
c  compute ri, beta, and eta

      nsc = nleg-1

c     We need the 'z' atom so we can use it below.  Put
c     it in rat(nleg+1).  No physical significance, just a handy
c     place to put it.
      if (ipol.gt.0) then
         rat(1,nleg+1) = rat(1,nleg)
         rat(2,nleg+1) = rat(2,nleg)
         rat(3,nleg+1) = rat(3,nleg) + 1.0
      endif

c     add rat(0) and ipot(0) (makes writing output easier)
      do 22 j = 1, 3
         rat(j,0) = rat(j,nleg)
   22 continue
      ipot(0) = ipot(nleg)

      nangle = nleg
      if (ipol.gt.0) then 
c        in polarization case we need one more rotation
         nangle = nleg + 1
      endif
      do 100  j = 1, nangle

c        for euler angles at point i, need th and ph (theta and phi)
c        from rat(i+1)-rat(i)  and  thp and php
c        (theta prime and phi prime) from rat(i)-rat(i-1)
c
c        Actually, we need cos(th), sin(th), cos(phi), sin(phi) and
c        also for angles prime.  Call these  ct,  st,  cp,  sp

c        i = (j)
c        ip1 = (j+1)
c        im1 = (j-1)
c        except for special cases...
         ifix = 0
         if (j .eq. nsc+1)  then
c           j+1 'z' atom, j central atom, j-1 last path atom
            i = 0
            ip1 = 1
            if (ipol.gt.0) then
               ip1 = nleg+1
            endif
            im1 = nsc

         elseif (j .eq. nsc+2)  then
c           j central atom, j+1 first path atom, j-1 'z' atom
            i = 0
            ip1 = 1
            im1 = nleg+1
            ifix = 1
         else
            i = j
            ip1 = j+1
            im1 = j-1
         endif

         x = rat(1,ip1) - rat(1,i)
         y = rat(2,ip1) - rat(2,i)
         z = rat(3,ip1) - rat(3,i)
         call trig (x, y, z, ctp, stp, cpp, spp)
         x = rat(1,i) - rat(1,im1)
         y = rat(2,i) - rat(2,im1)
         z = rat(3,i) - rat(3,im1)
         call trig (x, y, z, ct, st, cp, sp)

c        Handle special case, j=central atom, j+1 first
c        path atom, j-1 is 'z' atom.  Need minus sign
c        for location of 'z' atom to get signs right.
         if (ifix .eq. 1)  then
            x = 0
            y = 0
            z = 1.0
            call trig (x, y, z, ct, st, cp, sp)
            ifix = 0
         endif

c        cppp = cos (phi prime - phi)
c        sppp = sin (phi prime - phi)
         cppp = cp*cpp + sp*spp
         sppp = spp*cp - cpp*sp
         phi  = atan2(sp,cp)
         phip = atan2(spp,cpp)

c        alph = exp(i alpha)  in ref eqs 18
c        beta = cos (beta)         
c        gamm = exp(i gamma)
         alph = -(st*ctp - ct*stp*cppp - coni*stp*sppp)
         beta(j) = ct*ctp + st*stp*cppp
c        watch out for roundoff errors
         if (beta(j) .lt. -1) beta(j) = -1
         if (beta(j) .gt.  1) beta(j) =  1
         gamm = -(st*ctp*cppp - ct*stp + coni*st*sppp)
         call arg(alph,phip-phi,alpha(j))
         beta(j) = acos(beta(j))
         call arg(gamm,phi-phi,gamma(j))
c       Convert from the rotation of FRAME used before to the rotation 
c       of VECTORS used in ref.
         dumm = alpha(j)
         alpha(j) =  pi- gamma(j)
         gamma(j) =  pi- dumm

         if (j .le. nleg)  then
            ri(j) = dist (rat(1,i), rat(1,im1))
         endif
  100 continue

c     Make eta(i) = alpha(i-1) + gamma(i). 
c     We'll need alph(nangle)=alph(0)
      alpha(0) = alpha(nangle)
      do 150  j = 1, nleg
         eta(j) = alpha(j-1) + gamma(j)
  150 continue
      if (ipol.gt.0) then
         eta(0) = gamma(nleg+1)
         eta(nleg+1) = alpha(nleg)
      endif

      return
      end
