#!/bin/bash
__dir_script="."

## setup environment
function dotenv_configure(){
  # Configure Bash.
  perl -i -pe \
       'BEGIN{undef $/;} s/###BEGIN_ADD_BASHRC.*?###END_ADD_BASHRC//smg' \
         "${HOME}/.bashrc"
  cat "${__dir_script}/bash/bashrc.sh" >> "${HOME}/.bashrc"

  # Add custom inputrc (arrow support).
  cp "${__dir_script}/bash/inputrc" "${HOME}/.inputrc"

  # Configure vim.
  # Install vundle.
  mkdir --parents "${HOME}/.vim/bundle"
  git clone https://github.com/VundleVim/Vundle.vim.git "${HOME}/.vim/bundle/vundle.vim"
  wget https://raw.githubusercontent.com/amix/vimrc/master/vimrcs/basic.vim \
       -O "${HOME}/.vimrc"
  perl -i -pe \
       'BEGIN{undef $/;} s/"""BEGIN_ADD_VIMRC.*?"""END_ADD_VIMRC//smg' \
         "${HOME}/.vimrc"
  cat "${__dir_script}/vim/.vimrc" >> "${HOME}/.vimrc"
  sudo sh -c "cat ${__dir_script}/vim/cpp.vim >> /usr/share/vim/vim74/syntax/cpp.vim"

  # Configure py-format.
  sudo mkdir --parents /usr/lib/py-format
  cp "${__dir_script}/vim/py-format.py" /usr/lib/py-format/py-format.py

  # Set vim defaults.
  sudo update-alternatives --install /usr/bin/editor editor /usr/bin/vim 1
  sudo update-alternatives --set editor /usr/bin/vim
  sudo update-alternatives --install /usr/bin/vi vi /usr/bin/vim 1
  sudo update-alternatives --set vi /usr/bin/vim

  # Tmux.
  wget https://raw.githubusercontent.com/jordansissel/tmux/master/trunk/examples/t-williams.conf \
       -O "${HOME}/.tmux.conf"
  perl -i -pe \
       'BEGIN{undef $/;} s/"""BEGIN_ADD_TMUX.*?"""END_ADD_TMUX//smg' \
         "${HOME}/.tmux.conf"
  sed -i "s/^new/#new/g" "${HOME}/.tmux.conf"
  sed -i "s/^selectw/#selectw/g" "${HOME}/.tmux.conf"
  cat "${__dir_script}/tmux/.tmux.conf" >> "${HOME}/.tmux.conf"

  # Thunar.
  echo '(gtk_accel_path "<Actions>/ThunarWindow/open-parent" "BackSpace")' >> "${HOME}/.config/Thunar/accels.scm"
  thunar -q

  # terminal palette
  dconf reset -f /org/gnome/terminal/legacy/profiles:/
  dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/visible-name "'Default'"
  # Smyck
  # wget -O xt  https://raw.githubusercontent.com/Mayccoll/Gogh/master/themes/smyck.sh && \
  # chmod +x xt && ./xt && rm xt
  # Chalk
  # wget -O xt  https://raw.githubusercontent.com/Mayccoll/Gogh/master/themes/chalk.sh && \
  #  chmod +x xt && ./xt && rm xt
  # Monokai Dark
  # wget -O xt  https://raw.githubusercontent.com/Mayccoll/Gogh/master/themes/monokai.dark.sh && \
  #  chmod +x xt && ./xt && rm xt

  __purple_dark="#757550507B7B"
  __purple_light="#ADAD7F7FA8A8"
  __blue_light="#72729F9FCFCF"
  __blue_dark="#34346565A4A4"
  __red_light="#CCCC00000000"
  __pink_dark="#EEEE38383838"
  __palette_original=$(gconftool-2 --get /apps/gnome-terminal/profiles/Default/palette)
  __palette_original="#000000000000:${__red_light}:#4E4E9A9A0606:#C4C4A0A00000:${__blue_dark}:${purple_dark}:#060698209A9A:#D3D3D7D7CFCF:#555557575353:#EFEF29292929:#8A8AE2E23434:#FCFCE9E94F4F:#72729F9FCFCF:#ADAD7F7FA8A8:#3434E2E2E2E2:#EEEEEEEEECEC"
  __palette_updated="#000000000000:${__pink_dark}:#4E4E9A9A0606:#C4C4A0A00000:${__blue_light}:${__purple_light}:#060698209A9A:#D3D3D7D7CFCF:#555557575353:#EFEF29292929:#8A8AE2E23434:#FCFCE9E94F4F:${__blue_light}:#ADAD7F7FA8A8:#3434E2E2E2E2:#EEEEEEEEECEC"
  gconftool-2 --set /apps/gnome-terminal/profiles/Default/palette --type string "${__palette_updated}"

  # terminal background
  __plum_dark="#1D1D14142525"
  __opacity="0.965"
  gconftool-2 --set /apps/gnome-terminal/profiles/Default/background_color --type string "${__plum_dark}"
  gconftool-2 --set /apps/gnome-terminal/profiles/Default/background_darkness --type float "${__opacity}"

  profile=$(gsettings get org.gnome.Terminal.ProfilesList default)
  profile=${profile:1:-1} # remove leading and trailing single quotes
  gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile}/" background-color "'${__plum_dark}'"
  gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile}/" palette "'${__palette_updated}'"

  dconf write /org/gnome/terminal/legacy/profiles:/:221c1bdc-8bbe-48c1-bacd-21dcbbf0727a/background-color "'$__plum_dark'"
  dconf write /org/gnome/terminal/legacy/profiles:/:221c1bdc-8bbe-48c1-bacd-21dcbbf0727a/palette ['#000000000000', '#EEEE38383838', '#4E4E9A9A0606', '#C4C4A0A00000', '#72729F9FCFCF', '#ADAD7F7FA8A8', '#060698209A9A', '#D3D3D7D7CFCF', '#555557575353', '#EFEF29292929', '#8A8AE2E23434', '#FCFCE9E94F4F', '#72729F9FCFCF', '#ADAD7F7FA8A8', '#3434E2E2E2E2', '#EEEEEEEEECEC']
}


####################################################################
## Install.
####################################################################
dotenv_configure
