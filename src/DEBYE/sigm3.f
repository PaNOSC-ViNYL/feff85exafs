      subroutine sigm3(sig1, sig2, sig3, tk, alphat, thetae)
c     using correlated Einstein-model with a morse potential
c     Nguyen Van Hung & J.J.Rehr Phys. Rev. B 56 , 43

      implicit double precision (a-h, o-z)
      real sig02,  sig01, z
c     dimension alphat=[1/anstroems]
      parameter (bohr = 0.529 177 249d0)
      parameter(three= 3)
      parameter(four= 4 )
      parameter(fourthird= four/three)
      parameter(threequater= three/four)
              
      alphat= alphat * bohr  
      z=exp(- thetae/tk)
      sig02= (1-z)/ (1+z) * sig2
      sig01 = alphat * sig02 * threequater
      sig1 = sig01 * sig2 / sig02
      sig3 = (2- fourthird * (sig02/sig2) **2)* sig1 * sig2

      return
      end
