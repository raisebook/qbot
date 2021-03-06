use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: Mix.env

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :compliance do
  set include_erts: true
  set include_src: false
  set cookie: :"r&)yXF~oKN>efpTFabfi=3SwBAn:_XTIBM;K8I2x!)!EifIf<#;ZbZD=+hCz`nI~"
end

environment :staging do
  set include_erts: true
  set include_src: false
  set cookie: :"L9fB;d1GncmtTh,Yy._K{L~OQ),&qk/!}NFNy~bXZ/S8(`9r6OP+B@m!nyb1k-f"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"W$A?:U%Qa5(H6KgOBN6vutuJh)]yc68:fv%dpUT1F_nfvO?DNg*c_Nh~Z(F~~XZh"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :qbot do
  set version: current_version(:qbot)
end
