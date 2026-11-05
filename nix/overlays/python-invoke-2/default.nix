{ ... }:

# nixpkgs-unstable bumped `python3Packages.invoke` to 3.0.3. The latest fabric
# release (3.2.3) still declares `invoke<3.0,>=2.0`, so nixpkgs marks it
# `meta.broken`. Every package that pulls fabric — most visibly `azure-cli`,
# used here by `nyx.modules.shell.azurecli` — then refuses to evaluate with:
#
#   Refusing to evaluate package 'python3.14-fabric-3.2.3' because it has problems: broken
#
# Downgrade invoke to 2.2.0 for every python package set so fabric, paramiko and
# their dependents agree on a single version (a partial override would trip
# `pythonCatchConflictsPhase` with two invokes in the closure).
#
# Drop this overlay once fabric supports invoke 3 and nixpkgs ships that bump:
# https://github.com/fabric/fabric/issues/2376
#
# We hook `pythonPackagesExtensions`, which nixpkgs applies to every python
# package set (python312Packages, python313Packages, python314Packages, ...).

_final: prev:

{
  pythonPackagesExtensions = (prev.pythonPackagesExtensions or [ ]) ++ [
    (_pySelf: pySuper: {
      invoke = pySuper.invoke.overrideAttrs (_old: {
        version = "2.2.0";
        src = prev.fetchPypi {
          pname = "invoke";
          version = "2.2.0";
          hash = "sha256-7my7EBrxqFnH/oTyomTAWQILDLf+NTX5QkMAq1aPa9U=";
        };
        # 2.2.0 has no runtime dependencies, and its vendored test suite is
        # skipped for 3.0.3 upstream as well.
        dependencies = [ ];
        nativeCheckInputs = [ ];
        doCheck = false;
      });
    })
  ];
}
