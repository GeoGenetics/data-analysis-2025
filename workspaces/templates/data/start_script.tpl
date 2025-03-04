set -e
# install and start code-server
curl -fsSL https://code-server.dev/install.sh | sh -s -- --method=standalone --prefix=/tmp/code-server --version 4.8.3
/tmp/code-server/bin/code-server --auth none --port 13337 >/tmp/code-server.log 2>&1 &
sudo locale-gen en_US.UTF-8
# Install extensions for bash, python, and R
/tmp/code-server/bin/code-server --install-extension REditorSupport.r
/tmp/code-server/bin/code-server --install-extension ms-python.python
/tmp/code-server/bin/code-server --install-extension anwar.papyrus-pdf
/tmp/code-server/bin/code-server --install-extension mads-hartmann.bash-ide-vscode


# mkdir -p /home/kasm-user/Desktop

#coder dotfiles -y ${dotfiles_url} &

echo ". /home/${username}/.bashrc" >>/home/${username}/.bash_profile

wget -O /home/${username}/bashrc https://raw.githubusercontent.com/genomewalker/dotfiles/master/shell/bash/.bashrc

cat /home/${username}/bashrc >>/home/${username}/.bashrc
rm /home/${username}/bashrc
. /home/${username}/.bash_profile

if [ ! -d /home/${username}/opt ]; then

  mkdir /home/${username}/opt
  wget -O /tmp/Mambaforge.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
  bash /tmp/Mambaforge.sh -b -p /home/${username}/opt/conda

  source /home/${username}/opt/conda/etc/profile.d/conda.sh

  conda init bash

  #/dockerstartup/kasm_default_profile.sh /dockerstartup/vnc_startup.sh /dockerstartup/kasm_startup.sh &
  # echo "source $${STARTUPDIR}/generate_container_user" >>/home/${username}/.bashrc

  . /home/${username}/.bash_profile

  conda config --set auto_activate_base false
  conda config --add channels defaults
  conda config --add channels bioconda
  conda config --add channels conda-forge
  conda config --set channel_priority strict

  cat <<EOF >/tmp/day1.yml
name: day1
channels:
  - conda-forge
  - bioconda
  - defaults
  - genomewalker
dependencies:
  - python=3.9
  - htslib
  - samtools
  - bowtie2
  - seqkit
  - shellcheck
EOF

  cat <<EOF >/tmp/day2.yml
name: day2
channels:
  - conda-forge
  - bioconda
  - defaults
  - genomewalker
dependencies:
  - python=3.9
  - snakemake
  - snakefmt
  - pip
  - pip:
      - dash_bootstrap_components 
      - fire
      - dash
      - codecarbon
EOF

  cat <<EOF >/tmp/r.yml
name: r
channels:
  - conda-forge
  - bioconda
  - defaults
dependencies:
  - python=3.9
  - shellcheck
  - r
  - radian
  - r-languageserver
  - r-httpgd
  - r-showtext
  - r-rcpp
  - r-tidyverse
EOF

  mamba env create -f /tmp/r.yml
  rm /tmp/r.yml
  mamba env create -f /tmp/day1.yml
  rm /tmp/day1.yml
  mamba env create -f /tmp/day2.yml
  rm /tmp/day2.yml

  echo "conda activate day1" >>/home/${username}/.bashrc

  cat <<EOF >/home/${username}/.Rprofile
Sys.setenv(TERM_PROGRAM="vscode")
if (interactive() && Sys.getenv("RSTUDIO") == "") {
  source(file.path(Sys.getenv("HOME"), ".vscode-R", "init.R"))
}

if (interactive() && Sys.getenv("TERM_PROGRAM") == "vscode") {
  showtext::showtext_auto()
  if ("httpgd" %in% .packages(all.available = TRUE)) {
    options(vsc.plot = FALSE)
    options(device = function(...) {
      httpgd::hgd(silent = TRUE)
      .vsc.browser(httpgd::hgd_url(history = FALSE), viewer = "Beside")
    })
  }
}

EOF

  mkdir -p /home/${username}/.local/share/code-server/User
  cat <<EOF >/home/${username}/.local/share/code-server/User/settings.json
{
    "files.dialog.defaultPath": "/home/${username}/course",
    "r.plot.useHttpgd": true,
    "r.rpath.linux": "/home/${username}/opt/conda/envs/r/bin/R",
    "r.rterm.linux": "/home/${username}/opt/conda/envs/r/bin/radian",
    "r.bracketedPaste": true,
    "r.rterm.option": [
        "--no-save",
        "--no-restore",
        "--r-binary=/home/${username}/opt/conda/envs/r/bin/R"
    ],
    "r.alwaysUseActiveTerminal": true,
}
EOF

fi
. /home/${username}/.bash_profile
