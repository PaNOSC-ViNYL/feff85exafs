      subroutine phamp (rmt, pu, qu, ck, jl, nl, jlp, nlp, ikap,
     1                  ph, amp)
c     calculate phase shift at mt radius
c     needs to calculate atan of complex variable (coded below)
      implicit double precision (a-h, o-z)
      include '../HEADERS/const.h'
      include '../HEADERS/dim.h'
      external besjn, atan2c

      complex*16 pu, qu, ck,  jl, nl, jlp, nlp, ph, amp
      complex*16 xkr, a, b, factor

c     initialize staff
      xkr = ck*rmt
      isign=1
      if (ikap.lt.0) isign = -1
      a = ck*alphfs
      factor = isign*a/(1+sqrt(1+a**2))

c     find a and b that pu = rmt*(a*jl+b*nl), qu=factor*rmt*(a*jlp+b*nlp)
      a = isign*ck*xkr* (pu*nlp - qu*nl/factor)
      b = isign*ck*xkr* (qu*jl/factor - pu*jlp)

c     pu =  amp * rmt * (jl*cos(ph) - nl*sin(ph))
c     qu =  amp * rmt * (jlp*cos(ph) - nlp*sin(ph)) * factor
c     tan(ph) = - b/a
      b = -b
      call atan2c ( a, b, amp, ph)

      return
      end
      subroutine atancc(temp, phx)
c     phx=atan(temp), for complex numbers
      implicit double precision (a-h, o-z)
      complex*16 temp, phx

      xx = dble (temp)
      yy = dimag(temp)
      if (xx .ne. 0)  then
         alph = (1 - xx**2 - yy**2)
         alph = sqrt(alph**2 + 4*xx**2) - alph
         alph = alph / (2 * xx)
         alph = atan (alph)
      else
         alph = 0
      endif
      beta = (xx**2 + (yy+1)**2) / (xx**2 + (yy-1)**2)
      beta = log(beta) / 4
      phx = dcmplx (alph, beta)

      return
      end

      subroutine atan2c(a, b, ampl, phx)
c     for complex a, b find complex ampl, phx such that:
c     a= ampl*cos(phx)  and  b= ampl*sin(phx)
c     phx=atan(b/a)
      implicit double precision (a-h, o-z)
      parameter (pi = 3.14159 26535 89793 23846 26433d0)
      complex*16 a, b, ampl, phx, temp

      aa = abs(a)
      bb = abs(b)
      if (aa+bb.eq. 0) then
         ampl=0.d0
         phx =0.d0
      elseif ( aa.gt.bb) then
         temp = b/a
         call atancc ( temp, phx)
         ampl = a / cos(phx)
      else
         temp = a/b
         call atancc ( temp, phx)
         phx = pi / 2 - phx
         ampl = b/sin(phx)
      endif

      if (dble(ampl).lt. 0.d0) then
         ampl = -ampl
         phx = phx + pi
      endif

      return
      end
