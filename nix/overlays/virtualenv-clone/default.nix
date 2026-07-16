{ ... }:

# Disable the broken `test_clone_contents` test in python*Packages.virtualenv-clone.
#
# As of nixpkgs-unstable in mid-2026, virtualenv 21.x writes an
# `original-virtualenv = /path/to/source_venv` line into the cloned
# `pyvenv.cfg`. virtualenv-clone 0.5.7 does not rewrite that line, so its own
# test suite (which greps the cloned files for the source path) fails. This
# breaks any package that depends on it — most visibly, `pipenv`.
#
# Upstream fix will presumably be a virtualenv-clone bump or a virtualenv
# behaviour change; until then we deselect that single test rather than
# skipping the whole check phase.
#
# We hook `pythonPackagesExtensions`, which nixpkgs applies to every python
# package set (python312Packages, python313Packages, python314Packages, and
# any private one that `pipenv` may spin up).

_final: prev:

{
  pythonPackagesExtensions = (prev.pythonPackagesExtensions or [ ]) ++ [
    (_pySelf: pySuper: {
      virtualenv-clone = pySuper.virtualenv-clone.overridePythonAttrs (old: {
        disabledTests = (old.disabledTests or [ ]) ++ [
          "test_clone_contents"
        ];
      });
    })
  ];
}
