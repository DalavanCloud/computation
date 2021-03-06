let
  pkgs = import <nixpkgs> {};

in {
  canary = { n, commit }: pkgs.stdenv.mkDerivation {
    name = "avers";
    src = ./.;

    buildInputs = [
      pkgs.nodejs-10_x
      pkgs.jq
    ];

    buildPhase = ''
      HOME=$PWD npm ci
      ./node_modules/.bin/tsc
      npm --no-git-tag-version version patch
      cat package.json | jq 'del(.devDependencies) | .version = .version + "-alpha.${n}+${commit}"' > dist/package.json
    '';

    checkPhase = ''
      ./node_modules/.bin/tslint --project .
      ./node_modules/.bin/mocha dist
    '';

    installPhase = ''
      mv dist $out
      rm $out/*.test.*
    '';
  };

  head = pkgs.stdenv.mkDerivation {
    name = "avers";
    src = ./.;

    buildInputs = [
      pkgs.nodejs-10_x
      pkgs.jq
    ];

    buildPhase = ''
      HOME=$PWD npm ci
      ./node_modules/.bin/tsc
      cat package.json | jq 'del(.devDependencies)' > dist/package.json
    '';

    checkPhase = ''
      ./node_modules/.bin/tslint --project .
      ./node_modules/.bin/mocha dist
    '';

    installPhase = ''
      mv dist $out
      rm $out/*.test.*
    '';
  };
}