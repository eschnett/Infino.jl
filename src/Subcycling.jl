using ArgParse
using LinearAlgebra
using Plots
using Printf
using WriteVTK

include("Basic.jl")
include("ODESolver.jl")
include("Physical.jl")

#using .Basic
#using .ODESolver
#using .Physical

function parse_commandline()

  s = ArgParseSettings()
  @add_arg_table s begin
    "--nx", "-n"
    help = "number of points in each direction"
    arg_type = Int
    default = 101
    "--out_every"
    help = "output every so many steps"
    arg_type = Int
    default = 20
    "--cfl"
    help = "Courant factor"
    arg_type = Float64
    default = 0.25
    "--itlast"
    help = "maximum time steps"
    arg_type = Int
    default = 500
  end
  return parse_args(s)

end

function main()

  println("===================================================================")
  println("  Welcome to Subcycling Test !!!  ")
  println("===================================================================")

  params = parse_commandline()
  nx = params["nx"]
  itlast = params["itlast"]
  out_every = params["out_every"]
  cfl = params["cfl"]

  bbox = [[-4.0, 4.0], [-1.0, 1.0]]
  grid = Basic.Grid(nx, bbox, cfl)
  gfs = Basic.GridFunction(2, grid)

  yrange = (0, 1)
  a_psi = Animation()
  a_Pi = Animation()

  ###############
  # Intial Data #
  ###############
  println("Setting up initial conditions...")
  Physical.InitialData!(gfs)

  @printf("Simulation time: %.4f, iteration %d. E = %.4f\n",
          gfs.grid.time, 0, Physical.Energy(gfs))

  plt_psi = plot(gfs.levs[1].x, gfs.levs[1].u[1], ylim=(-1,1), label="psi")
  plt_psi = scatter!(gfs.levs[1].x, gfs.levs[1].u[1], label="")
  plt_psi = scatter!(gfs.levs[2].x, gfs.levs[2].u[1], label="")
  plt_Pi = plot(gfs.levs[1].x, gfs.levs[1].u[2], ylim=(-4,4), label="Pi")
  frame(a_psi, plt_psi)
  frame(a_Pi, plt_Pi)

  ##########
  # Evolve #
  ##########
  println("Start evolution...")
  for i = 1:itlast
    ODESolver.Evolve!(Physical.WaveRHS!, gfs)
    @printf("Simulation time: %.4f, iteration %d. E = %.4f\n",
            gfs.grid.time, i, Physical.Energy(gfs))

    if (mod(i, out_every) == 0)
      plt_psi = plot(gfs.levs[1].x, gfs.levs[1].u[1], ylim=(-1,1), label="psi")
      plt_psi = scatter!(gfs.levs[1].x, gfs.levs[1].u[1], label="")
      plt_psi = scatter!(gfs.levs[2].x, gfs.levs[2].u[1], label="")
      plt_Pi = plot(gfs.levs[1].x, gfs.levs[1].u[2], ylim=(-4,4), label="Pi")
      frame(a_psi, plt_psi)
      frame(a_Pi, plt_Pi)
    end
  end

  # output
  gif(a_psi, "psi.gif")
  gif(a_Pi, "Pi.gif")

  ########
  # Exit #
  ########
  println("-------------------------------------------------------------------")
  println("  Successfully Done")
  println("-------------------------------------------------------------------")

end

main()
