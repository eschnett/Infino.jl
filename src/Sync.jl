module Sync

function Prolongation(gfs, l, interp_in_time::Bool)
  levl  = gfs.grid.levs[l]
  nxa   = levl.nxa
  nbuf  = levl.nbuf
  if2c  = levl.if2c
  aligned = levl.aligned
  levsfs = gfs.levs

  for v in 1:gfs.nd
    u    = levsfs[l].u[v]
    uc_p = levsfs[l-1].u_p[v]
    if (interp_in_time)
      uc = levsfs[l-1].u[v]
      for il in 1:nbuf
        ir = nxa - il + 1
        icl = if2c[il]
        icr = if2c[ir]
        u[il] = ((aligned[il])
                 ? (uc[icl] + uc_p[icl]) * 0.5
                 : (uc[icl] + uc[icl+1] + uc_p[icl] + uc_p[icl+1]) * 0.25)
        u[ir] = ((aligned[ir])
                 ? (uc[icr] + uc_p[icr]) * 0.5
                 : (uc[icr] + uc[icr+1] + uc_p[icr] + uc_p[icr+1]) * 0.25)
      end
    else
      for il in 1:nbuf
        ir = nxa - il + 1
        icl = if2c[il]
        icr = if2c[ir]
        u[il] = ((aligned[il]) ? uc_p[icl] : (uc_p[icl] + uc_p[icl+1]) * 0.5)
        u[ir] = ((aligned[ir]) ? uc_p[icr] : (uc_p[icr] + uc_p[icr+1]) * 0.5)
      end
    end
  end
end

function Restriction()
end

end
