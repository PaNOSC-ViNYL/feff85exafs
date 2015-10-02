PROGRAM opconsAt
  USE atoms_inp
  USE potential_inp
  USE geometry_inp
  USE constants
  USE AtomicPotIO
  USE opcons_inp
  use par 
  use errorfile
  IMPLICIT NONE
  INTEGER iph, iph2, NComps, iAt, iAt2, iX, iY, iZ2, nnn
  INTEGER, ALLOCATABLE :: izComp(:), nAtComp(:)
  CHARACTER(2), ALLOCATABLE :: Components(:)
  CHARACTER(12), ALLOCATABLE :: EpsFiles(:)
  CHARACTER(2),EXTERNAL :: GetElement
  REAL(8),ALLOCATABLE :: rnrm(:)
  REAL(8) VTot, rNN, r, rCnt(3), point(3), x2, y2, z2, dX
  REAL(8),PARAMETER :: RTol  = (3.d0)**2
  INTEGER,PARAMETER :: NGrid = 200

  !KJ 1-2012:
  call par_begin
  if (worker) go to 400
  call OpenErrorfileAtLaunch('opconsat')	

  !CALL opcons_read
  !IF(.NOT.run_opcons) STOP 
  !if (.not. run_opcons) goto 400
  CALL opcons_init  

  CALL atoms_read
  CALL potential_read

  ALLOCATE(izComp(0:nph), Components(0:nph), nAtComp(0:nph), EpsFiles(0:nph), rnrm(0:nph))

  CALL ReadAtomicPots(nph, rnrm)
  PRINT*, 'nph, rnrm', nph, rnrm

  ! Find the number density of each component.
  VTot = 0.d0
  DO iph = 0, nph
     VTot = VTot + xnatph(iph)*4.d0/3.d0*pi*(rnrm(iph)*bohr)**3
  END DO

  DO iph = 0, nph
     IF(NumDens(iph).lt.0.d0) NumDens(iph) = xnatph(iph)/VTot
     ! test with numDens = 1. Should give same loss as input file for a single file.
     IF(.FALSE.) THEN
        IF(iph.ne.0) THEN
           NumDens(iph) = 1.d0
        ELSE
           NumDens(iph) = 0.d0
        END IF
     END IF
     Components(iph) = GetElement(iz(iph))
  END DO

  ! Get opcons{Element}.dat from database.
  !PRINT*, iz, nph
  CALL epsdb(iz,nph+1)

  ! Get the file names.
  DO iph = 0, nph
     EpsFiles(iph) = 'opcons' // TRIM(ADJUSTL(Components(iph))) // '.dat'
     PRINT*, Components(iph), NumDens(iph), EpsFiles(iph)
  END DO
  NComps = nph + 1
  CALL AddEps(EpsFiles,NComps,NumDens,print_eps)

  !KJ 1-2012:
400 call par_barrier
  call par_end
  call WipeErrorfileAtFinish
  stop


END PROGRAM opconsAt
