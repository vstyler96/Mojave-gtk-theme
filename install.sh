#! /usr/bin/env bash

. config.sh
export SCALE_FACTORS=$( seq -s' ' 2 $MAX_SCALE_FACTOR )

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SRC_DIR="${REPO_DIR}/src"

ROOT_UID=0
DEST_DIR=

# Destination directory
if [[ "$UID" -eq "$ROOT_UID" ]]; then
  DEST_DIR="/usr/share/themes"
elif [[ -n "$XDG_DATA_HOME" ]]; then
  DEST_DIR="$XDG_DATA_HOME/themes"
elif [[ -d "$HOME/.themes" ]]; then
  DEST_DIR="$HOME/.themes"
elif [[ -d "$HOME/.local/share/themes" ]]; then
  DEST_DIR="$HOME/.local/share/themes"
else
  DEST_DIR="$HOME/.themes"
fi

SASSC_OPT="-M -t expanded"

THEME_NAME=Mojave
COLOR_VARIANTS=('-Light' '-Dark')
OPACITY_VARIANTS=('' '-solid')
ALT_VARIANTS=('' '-alt')
SMALL_VARIANTS=('' '-small')
THEME_VARIANTS=('' '-blue' '-purple' '-pink' '-red' '-orange' '-yellow' '-green' '-grey' '-cherry')
ICON_VARIANTS=('' '-normal' '-gnome' '-ubuntu' '-arch' '-manjaro' '-fedora' '-debian' '-void' '-nixos')

# COLORS
CDEF=" \033[0m"                                     # default color
CCIN=" \033[0;36m"                                  # info color
CGSC=" \033[0;32m"                                  # success color
CRER=" \033[0;31m"                                  # error color
CWAR=" \033[0;33m"                                  # warning color
b_CDEF=" \033[1;37m"                                # bold default color
b_CCIN=" \033[1;36m"                                # bold info color
b_CGSC=" \033[1;32m"                                # bold success color
b_CRER=" \033[1;31m"                                # bold error color
b_CWAR=" \033[1;33m"                                # bold warning color

# Echo like ... with flag type and display message colors
prompt () {
  case ${1} in
    "-s"|"--success")
      echo -e "${b_CGSC}${@/-s/}${CDEF}";;    # print success message
    "-e"|"--error")
      echo -e "${b_CRER}${@/-e/}${CDEF}";;    # print error message
    "-w"|"--warning")
      echo -e "${b_CWAR}${@/-w/}${CDEF}";;    # print warning message
    "-i"|"--info")
      echo -e "${b_CCIN}${@/-i/}${CDEF}";;    # print info message
    *)
    echo -e "$@"
    ;;
  esac
}

usage() {
  printf "%s\n" "Usage: $0 [OPTIONS...]"
  printf "\n%s\n" "OPTIONS:"
  printf "  %-25s%s\n" "-d, --dest DIR" "Specify theme destination directory (Default: ${DEST_DIR})"
  printf "  %-25s%s\n" "-n, --name NAME" "Specify theme name (Default: ${THEME_NAME})"
  printf "  %-25s%s\n" "-o, --opacity VARIANTS" "Specify theme opacity variant(s) [standard|solid] (Default: All variants)"
  printf "  %-25s%s\n" "-c, --color VARIANTS" "Specify theme color variant(s) [light|dark] (Default: All variants)"
  printf "  %-25s%s\n" "-a, --alt VARIANTS" "Specify theme titilebutton variant(s) [standard|alt] (Default: All variants)"
  printf "  %-25s%s\n" "-s, --small VARIANTS" "Specify theme titilebutton size variant(s) [standard|small] (Default: All variants)"
  printf "  %-25s%s\n" "-t, --theme VARIANTS" "Specify primary theme color [blue|purple|pink|red|orange|yellow|green|grey|cherry|all] (Default: MacOS blue)"
  printf "  %-25s%s\n" "-i, --icon VARIANTS" "Specify activities icon variant(s) for gnome-shell [standard|normal|gnome|ubuntu|arch|manjaro|fedora|debian|void|nixos] (Default: standard variant)"
  printf "  %-25s%s\n" "-g, --gdm" "Install GDM theme, this option need root user authority! please run this with sudo"
  printf "  %-25s%s\n" "-r, --revert" "revert GDM theme, this option need root user authority! please run this with sudo"
  printf "  %-25s%s\n" "-h, --help" "Show this help"
}

install() {
  local dest="${1}"
  local name="${2}"
  local color="${3}"
  local opacity="${4}"
  local alt="${5}"
  local small="${6}"
  local theme="${7}"
  local icon="${8}"

  [[ "${color}" == '-light' ]] && local ELSE_LIGHT="${color}"
  [[ "${color}" == '-dark' ]] && local ELSE_DARK="${color}"

  local THEME_DIR="${1}/${2}${3}${4}${5}${6}${7}"

  [[ -d "${THEME_DIR}" ]] && rm -rf "${THEME_DIR}"

  prompt -i "Installing '${THEME_DIR}'..."

  rm -rf "${SRC_DIR}/sass/_theme-variant-temp.scss"
  cp -rf "${SRC_DIR}/sass/_theme-variant.scss" "${SRC_DIR}/sass/_theme-variant-temp.scss"

  if [[ "$accent" = "true" ]] ; then
    theme_color
  fi

  mkdir -p                                                                                   "${THEME_DIR}"
  cp -r "${REPO_DIR}/COPYING"                                                                "${THEME_DIR}"

  echo "[Desktop Entry]" >>                                                                  "${THEME_DIR}/index.theme"
  echo "Type=X-GNOME-Metatheme" >>                                                           "${THEME_DIR}/index.theme"
  echo "Name=${2}${3}${4}${5}${6}${7}" >>                                                    "${THEME_DIR}/index.theme"
  echo "Comment=An Stylish Gtk+ theme based on Elegant Design" >>                            "${THEME_DIR}/index.theme"
  echo "Encoding=UTF-8" >>                                                                   "${THEME_DIR}/index.theme"
  echo "" >>                                                                                 "${THEME_DIR}/index.theme"
  echo "[X-GNOME-Metatheme]" >>                                                              "${THEME_DIR}/index.theme"
  echo "GtkTheme=${2}${3}${4}${5}${6}${7}" >>                                                "${THEME_DIR}/index.theme"
  echo "MetacityTheme=${2}${3}${4}${5}${6}${7}" >>                                           "${THEME_DIR}/index.theme"
  echo "IconTheme=McMojave-circle${2}${3}" >>                                                "${THEME_DIR}/index.theme"
  echo "CursorTheme=McMojave Cursors" >>                                                     "${THEME_DIR}/index.theme"
  echo "ButtonLayout=close,minimize,maximize:menu" >>                                        "${THEME_DIR}/index.theme"

  mkdir -p                                                                                   "${THEME_DIR}/gnome-shell"
  cp -r "${SRC_DIR}/assets/gnome-shell/icons"                                                "${THEME_DIR}/gnome-shell"
  cp -r "${SRC_DIR}/main/gnome-shell/pad-osd.css"                                            "${THEME_DIR}/gnome-shell"
  sassc $SASSC_OPT "${SRC_DIR}/main/gnome-shell/shell-${GS_VERSION}/gnome-shell${color}${opacity}.scss" "${THEME_DIR}/gnome-shell/gnome-shell.css"
  cp -r "${THEME_DIR}/gnome-shell/gnome-shell.css"                                           "${THEME_DIR}/gnome-shell/gdm3.css"
  cp -r "${SRC_DIR}/assets/gnome-shell/common-assets"                                        "${THEME_DIR}/gnome-shell/assets"

  if [[ ${theme} != '-default' ]]; then
    cp -r ${SRC_DIR}/assets/gnome-shell/common-assets${theme}/*'.svg'                        "${THEME_DIR}/gnome-shell/assets"
  fi

  cp -r "${SRC_DIR}/assets/gnome-shell/assets${color}/"*'.svg'                               "${THEME_DIR}/gnome-shell/assets"
  cp -r "${SRC_DIR}/assets/gnome-shell/assets${color}/background.png"                        "${THEME_DIR}/gnome-shell/assets"
  cp -r "${SRC_DIR}/assets/gnome-shell/activities${color}/activities${icon}.svg"             "${THEME_DIR}/gnome-shell/assets/activities.svg"
  cp -r "${SRC_DIR}/assets/gnome-shell/activities-Dark/activities${icon}.svg"                "${THEME_DIR}/gnome-shell/assets/activities-white.svg"
  cd "${THEME_DIR}/gnome-shell"
  mv -f assets/no-events.svg no-events.svg
  mv -f assets/process-working.svg process-working.svg
  mv -f assets/no-notifications.svg no-notifications.svg

  mkdir -p                                                                                   "${THEME_DIR}/gtk-2.0"
  cp -r "${SRC_DIR}/main/gtk-2.0/gtkrc${color}${theme}"                                      "${THEME_DIR}/gtk-2.0/gtkrc"
  cp -r "${SRC_DIR}/main/gtk-2.0/menubar-toolbar${color}.rc"                                 "${THEME_DIR}/gtk-2.0/menubar-toolbar.rc"
  cp -r "${SRC_DIR}/main/gtk-2.0/common/"*'.rc'                                              "${THEME_DIR}/gtk-2.0"
  cp -r "${SRC_DIR}/assets/gtk-2.0/assets${color}"                                           "${THEME_DIR}/gtk-2.0/assets"

  if [[ ${theme} != '-default' ]]; then
    cp -r "${SRC_DIR}/assets/gtk-2.0/assets${color}${theme}/"*'.png'                         "${THEME_DIR}/gtk-2.0/assets"
  fi

  mkdir -p                                                                                   "${THEME_DIR}/gtk-3.0"
  cp -r "${SRC_DIR}/assets/gtk/common-assets/assets"                                         "${THEME_DIR}/gtk-3.0"

  if [[ ${theme} != '-default' ]]; then
    cp -r "${SRC_DIR}/assets/gtk/common-assets/assets${theme}/"*'.png'                       "${THEME_DIR}/gtk-3.0/assets"
  fi

  cp -r "${SRC_DIR}/assets/gtk/windows-assets/titlebutton${alt}${small}"                     "${THEME_DIR}/gtk-3.0/windows-assets"
  cp -r "${SRC_DIR}/assets/gtk/thumbnails/thumbnail${color}${theme}.png"                     "${THEME_DIR}/gtk-3.0/thumbnail.png"
  sassc $SASSC_OPT "${SRC_DIR}/main/gtk-3.0/gtk${color}${opacity}.scss"                      "${THEME_DIR}/gtk-3.0/gtk.css"
  sassc $SASSC_OPT "${SRC_DIR}/main/gtk-3.0/gtk-Dark${opacity}.scss"                         "${THEME_DIR}/gtk-3.0/gtk-dark.css"

  glib-compile-resources --sourcedir="${THEME_DIR}/gtk-3.0" --target="${THEME_DIR}/gtk-3.0/gtk.gresource" "${SRC_DIR}/main/gtk-3.0/gtk.gresource.xml"
  rm -rf "${THEME_DIR}/gtk-3.0/"{assets,windows-assets,gtk.css,gtk-dark.css}
  echo '@import url("resource:///org/gnome/theme/gtk.css");' >>                              "${THEME_DIR}/gtk-3.0/gtk.css"
  echo '@import url("resource:///org/gnome/theme/gtk-dark.css");' >>                         "${THEME_DIR}/gtk-3.0/gtk-dark.css"

  mkdir -p                                                                                   "${THEME_DIR}/gtk-4.0"
  cp -r "${SRC_DIR}/assets/gtk/common-assets/assets"                                         "${THEME_DIR}/gtk-4.0"

  if [[ ${theme} != '-default' ]]; then
    cp -r "${SRC_DIR}/assets/gtk/common-assets/assets${theme}/"*'.png'                       "${THEME_DIR}/gtk-4.0/assets"
  fi

  cp -r "${SRC_DIR}/assets/gtk/windows-assets/titlebutton${alt}${small}"                     "${THEME_DIR}/gtk-4.0/windows-assets"
  cp -r "${SRC_DIR}/assets/gtk/thumbnails/thumbnail${color}${theme}.png"                     "${THEME_DIR}/gtk-4.0/thumbnail.png"
  sassc $SASSC_OPT "${SRC_DIR}/main/gtk-4.0/gtk${color}${opacity}.scss"                      "${THEME_DIR}/gtk-4.0/gtk.css"
  sassc $SASSC_OPT "${SRC_DIR}/main/gtk-4.0/gtk-Dark${opacity}.scss"                         "${THEME_DIR}/gtk-4.0/gtk-dark.css"

  glib-compile-resources --sourcedir="${THEME_DIR}/gtk-4.0" --target="${THEME_DIR}/gtk-4.0/gtk.gresource" "${SRC_DIR}/main/gtk-4.0/gtk.gresource.xml"
  rm -rf "${THEME_DIR}/gtk-4.0/"{assets,windows-assets,gtk.css,gtk-dark.css}
  echo '@import url("resource:///org/gnome/theme/gtk.css");' >>                              "${THEME_DIR}/gtk-4.0/gtk.css"
  echo '@import url("resource:///org/gnome/theme/gtk-dark.css");' >>                         "${THEME_DIR}/gtk-4.0/gtk-dark.css"

  mkdir -p                                                                                   "${THEME_DIR}/metacity-1"
  cp -r "${SRC_DIR}/main/metacity-1/metacity-theme${color}.xml"                              "${THEME_DIR}/metacity-1/metacity-theme-1.xml"
  cp -r "${SRC_DIR}/main/metacity-1/metacity-theme-3.xml"                                    "${THEME_DIR}/metacity-1"
  cp -r "${SRC_DIR}/assets/metacity-1/assets/"*'.png'                                        "${THEME_DIR}/metacity-1"
  cp -r "${SRC_DIR}/assets/metacity-1/thumbnail${color}.png"                                 "${THEME_DIR}/metacity-1/thumbnail.png"
  cd "${THEME_DIR}/metacity-1" && ln -s metacity-theme-1.xml metacity-theme-2.xml

  mkdir -p                                                                                   "${THEME_DIR}/xfwm4"
  cp -r "${SRC_DIR}/assets/xfwm4/assets${color}${small}/"*'.png'                             "${THEME_DIR}/xfwm4"
  cp -r "${SRC_DIR}/main/xfwm4/themerc${color}"                                              "${THEME_DIR}/xfwm4/themerc"

  mkdir -p                                                                                   "${THEME_DIR}/unity"
  cp -r "${SRC_DIR}/assets/unity/assets/"*'.png'                                             "${THEME_DIR}/unity"

  mkdir -p                                                                                   "${THEME_DIR}/cinnamon"
  sassc $SASSC_OPT "${SRC_DIR}/main/cinnamon/cinnamon${color}${opacity}.scss"                "${THEME_DIR}/cinnamon/cinnamon.css"
  cp -r "${SRC_DIR}/assets/cinnamon/common-assets"                                           "${THEME_DIR}/cinnamon/assets"

  if [[ ${theme} != '-default' ]]; then
    cp -r "${SRC_DIR}/assets/cinnamon/common-assets${theme}/"*'.svg'                         "${THEME_DIR}/cinnamon/assets"
  fi

  cp -r "${SRC_DIR}/assets/cinnamon/assets${color}/"*'.svg'                                  "${THEME_DIR}/cinnamon/assets"
  cp -r "${SRC_DIR}/assets/cinnamon/thumbnails/thumbnail${color}${theme}.png"                "${THEME_DIR}/cinnamon/thumbnail.png"

  mkdir -p                                                                                   "${THEME_DIR}/plank"
  cp -r "${SRC_DIR}/other/plank/Theme${color}/"*'.theme'                                     "${THEME_DIR}/plank"
}

clean() {
  local dest="${1}"
  local name="${2}"
  local color="${3}"
  local opacity="${4}"
  local alt="${5}"
  local small="${6}"
  local theme="${7}"

  local THEME_DIR="${1}/${2}${3}${4}${5}${6}${7}"

  [[ -d "${THEME_DIR}" ]] && rm -rf "${THEME_DIR}"
}

# Backup and install files related to GDM theme
GS_THEME_FILE="/usr/share/gnome-shell/gnome-shell-theme.gresource"
SHELL_THEME_FOLDER="/usr/share/gnome-shell/theme"
ETC_THEME_FOLDER="/etc/alternatives"
ETC_THEME_FILE="/etc/alternatives/gdm3.css"
ETC_NEW_THEME_FILE="/etc/alternatives/gdm3-theme.gresource"
UBUNTU_THEME_FILE="/usr/share/gnome-shell/theme/ubuntu.css"
UBUNTU_NEW_THEME_FILE="/usr/share/gnome-shell/theme/gnome-shell.css"
UBUNTU_YARU_THEME_FILE="/usr/share/gnome-shell/theme/Yaru/gnome-shell-theme.gresource"
POP_OS_THEME_FILE="/usr/share/gnome-shell/theme/Pop/gnome-shell-theme.gresource"

install_gdm() {
  local dest="${1}"
  local name="${2}"
  local color="${3}"
  local opacity="${4}"
  local theme="${5}"

  local GDM_THEME_DIR="${1}/${2}${3}${4}${5}"
  local YARU_GDM_THEME_DIR="$SHELL_THEME_FOLDER/Yaru/${2}${3}${4}${5}"
  local POP_GDM_THEME_DIR="$SHELL_THEME_FOLDER/Pop/${2}${3}${4}${5}"

  echo
  prompt -i "Installing ${2}${3}${4}${5} gdm theme..."

  if [[ -f "$GS_THEME_FILE" ]] && command -v glib-compile-resources >/dev/null ; then
    prompt -i "Installing '$GS_THEME_FILE'..."
    cp -an "$GS_THEME_FILE" "$GS_THEME_FILE.bak"
    glib-compile-resources \
      --sourcedir="$GDM_THEME_DIR/gnome-shell" \
      --target="$GS_THEME_FILE" \
      "${SRC_DIR}/main/gnome-shell/gnome-shell-theme.gresource.xml"
  fi

  if [[ -f "$UBUNTU_THEME_FILE" && -f "$GS_THEME_FILE.bak" ]]; then
    prompt -i "Installing '$UBUNTU_THEME_FILE'..."
    cp -an "$UBUNTU_THEME_FILE" "$UBUNTU_THEME_FILE.bak"
    cp -af "$GDM_THEME_DIR/gnome-shell/gnome-shell.css" "$UBUNTU_THEME_FILE"
  fi

  if [[ -f "$UBUNTU_NEW_THEME_FILE" && -f "$GS_THEME_FILE.bak" ]]; then
    prompt -i "Installing '$UBUNTU_NEW_THEME_FILE'..."
    cp -an "$UBUNTU_NEW_THEME_FILE" "$UBUNTU_NEW_THEME_FILE.bak"
    cp -af "$GDM_THEME_DIR"/gnome-shell/* "$SHELL_THEME_FOLDER"
  fi

  # > Ubuntu 18.04
  if [[ -f "$ETC_THEME_FILE" && -f "$GS_THEME_FILE.bak" ]]; then
    prompt -i "Installing Ubuntu GDM theme..."
    cp -an "$ETC_THEME_FILE" "$ETC_THEME_FILE.bak"
    [[ -d "$SHELL_THEME_FOLDER/$THEME_NAME" ]] && rm -rf "$SHELL_THEME_FOLDER/$THEME_NAME"
    cp -r "$GDM_THEME_DIR/gnome-shell" "$SHELL_THEME_FOLDER/$THEME_NAME"
    cd "$ETC_THEME_FOLDER"
    [[ -f "$ETC_THEME_FILE.bak" ]] && ln -sf "$SHELL_THEME_FOLDER/$THEME_NAME/gnome-shell.css" gdm3.css
  fi

  # > Ubuntu 20.04
  if [[ -d "$SHELL_THEME_FOLDER/Yaru" && -f "$GS_THEME_FILE.bak" ]]; then
    prompt -i "Installing Ubuntu GDM theme..."
    cp -an "$UBUNTU_YARU_THEME_FILE" "$UBUNTU_YARU_THEME_FILE.bak"
    rm -rf "$UBUNTU_YARU_THEME_FILE"

    sed -i "s|assets|resource:///org/gnome/shell/theme/assets|" "$GDM_THEME_DIR"/gnome-shell/gnome-shell.css

    glib-compile-resources \
      --sourcedir="$GDM_THEME_DIR"/gnome-shell \
      --target="$UBUNTU_YARU_THEME_FILE" \
      "$SRC_DIR"/main/gnome-shell/gnome-shell-theme.gresource.xml
  fi

  # > Pop_OS 20.04
  if [[ -d "$SHELL_THEME_FOLDER/Pop" && -f "$GS_THEME_FILE.bak" ]]; then
    prompt -i "Installing Pop_OS GDM theme..."
    cp -an "$POP_OS_THEME_FILE" "$POP_OS_THEME_FILE.bak"
    rm -rf "$POP_OS_THEME_FILE"

    glib-compile-resources \
      --sourcedir="$POP_GDM_THEME_DIR"/gnome-shell \
      --target="$POP_OS_THEME_FILE" \
      "$SRC_DIR"/main/gnome-shell/gnome-shell-theme.gresource.xml
  fi
}

revert_gdm() {
  if [[ -f "$GS_THEME_FILE.bak" ]]; then
    prompt -w "Reverting '$GS_THEME_FILE'..."
    rm -rf "$GS_THEME_FILE"
    mv "$GS_THEME_FILE.bak" "$GS_THEME_FILE"
  fi

  if [[ -f "$UBUNTU_THEME_FILE.bak" ]]; then
    prompt -w "Reverting '$UBUNTU_THEME_FILE'..."
    rm -rf "$UBUNTU_THEME_FILE"
    mv "$UBUNTU_THEME_FILE.bak" "$UBUNTU_THEME_FILE"
  fi

  if [[ -f "$UBUNTU_NEW_THEME_FILE.bak" ]]; then
    prompt -w "Reverting '$UBUNTU_NEW_THEME_FILE'..."
    rm -rf "$UBUNTU_NEW_THEME_FILE" "$SHELL_THEME_FOLDER"/{assets,no-events.svg,process-working.svg,no-notifications.svg}
    mv "$UBUNTU_NEW_THEME_FILE.bak" "$UBUNTU_NEW_THEME_FILE"
  fi

  # > Ubuntu 18.04
  if [[ -f "$ETC_THEME_FILE.bak" ]]; then

    prompt -w "reverting Ubuntu GDM theme..."

    rm -rf "$ETC_THEME_FILE"
    mv "$ETC_THEME_FILE.bak" "$ETC_THEME_FILE"
    [[ -d $SHELL_THEME_FOLDER/$THEME_NAME ]] && rm -rf $SHELL_THEME_FOLDER/$THEME_NAME
  fi

  # > Ubuntu 20.04
  if [[ -f "$UBUNTU_YARU_THEME_FILE.bak" ]]; then
    prompt -w "reverting Ubuntu GDM theme..."
    rm -rf "$UBUNTU_YARU_THEME_FILE"
    mv "$UBUNTU_YARU_THEME_FILE.bak" "$UBUNTU_YARU_THEME_FILE"
  fi

  # > Pop_OS 20.04
  if [[ -f "$POP_OS_THEME_FILE.bak" ]]; then
    prompt -w "reverting Pop_OS GDM theme..."
    rm -rf "$POP_OS_THEME_FILE"
    mv "$POP_OS_THEME_FILE.bak" "$POP_OS_THEME_FILE"
  fi
}

while [[ $# -gt 0 ]]; do
  case "${1}" in
    -d|--dest)
      dest="${2}"
      if [[ ! -d "${dest}" ]]; then
        prompt -i "Destination directory does not exist. Let's make a new one..."
        mkdir -p "${dest}"
      fi
      dest="$(cd "${dest}"; pwd)"
      shift 2
      ;;
    -n|--name)
      name="${2}"
      shift 2
      ;;
    -l|--libadwaita)
      libadwaita='true'
      shift 1
      ;;
    -g|--gdm)
      gdm='true'
      shift 1
      ;;
    -r|--revert)
      revert='true'
      shift 1
      ;;
    -a|--alt)
      shift
      for alt in "${@}"; do
        case "${alt}" in
          standard)
            alts+=("${ALT_VARIANTS[0]}")
            shift
            ;;
          alt)
            alts+=("${ALT_VARIANTS[1]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized alt variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -s|--small)
      shift
      for small in "${@}"; do
        case "${small}" in
          standard)
            smalls+=("${SMALL_VARIANTS[0]}")
            shift
            ;;
          small)
            smalls+=("${SMALL_VARIANTS[1]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized small variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -o|--opacity)
      shift
      for opacity in "${@}"; do
        case "${opacity}" in
          standard)
            opacities+=("${OPACITY_VARIANTS[0]}")
            shift
            ;;
          solid)
            opacities+=("${OPACITY_VARIANTS[1]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized opacity variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -c|--color)
      shift
      for color in "${@}"; do
        case "${color}" in
          light)
            colors+=("${COLOR_VARIANTS[0]}")
            shift
            ;;
          dark)
            colors+=("${COLOR_VARIANTS[1]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized color variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -t|--theme)
      accent='true'
      shift
      for theme in "${@}"; do
        case "${theme}" in
          default)
            themes+=("${THEME_VARIANTS[0]}")
            shift
            ;;
          blue)
            themes+=("${THEME_VARIANTS[1]}")
            shift
            ;;
          purple)
            themes+=("${THEME_VARIANTS[2]}")
            shift
            ;;
          pink)
            themes+=("${THEME_VARIANTS[3]}")
            shift
            ;;
          red)
            themes+=("${THEME_VARIANTS[4]}")
            shift
            ;;
          orange)
            themes+=("${THEME_VARIANTS[5]}")
            shift
            ;;
          yellow)
            themes+=("${THEME_VARIANTS[6]}")
            shift
            ;;
          green)
            themes+=("${THEME_VARIANTS[7]}")
            shift
            ;;
          grey)
            themes+=("${THEME_VARIANTS[8]}")
            shift
            ;;
          cherry)
            themes+=("${THEME_VARIANTS[9]}")
            shift
            ;;
          all)
            themes+=("${THEME_VARIANTS[@]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized theme variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
        prompt -w "\n  Install $theme color variants..."
      done
      ;;
    -i|--icon)
      shift
      for icon in "${@}"; do
        case "${icon}" in
          standard)
            icons+=("${ICON_VARIANTS[0]}")
            shift
            ;;
          normal)
            icons+=("${ICON_VARIANTS[1]}")
            shift
            ;;
          gnome)
            icons+=("${ICON_VARIANTS[2]}")
            shift
            ;;
          ubuntu)
            icons+=("${ICON_VARIANTS[3]}")
            shift
            ;;
          arch)
            icons+=("${ICON_VARIANTS[4]}")
            shift
            ;;
          manjaro)
            icons+=("${ICON_VARIANTS[5]}")
            shift
            ;;
          fedora)
            icons+=("${ICON_VARIANTS[6]}")
            shift
            ;;
          debian)
            icons+=("${ICON_VARIANTS[7]}")
            shift
            ;;
          void)
            icons+=("${ICON_VARIANTS[8]}")
            shift
            ;;
          nixos)
            icons+=("${ICON_VARIANTS[9]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized icon variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      prompt -e "ERROR: Unrecognized installation option '$1'."
      prompt -i "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

#  Check command avalibility
function has_command() {
  command -v $1 > /dev/null
}

#  Install needed packages
install_package() {
  if [ ! "$(which sassc 2> /dev/null)" ]; then
    echo sassc needs to be installed to generate the css.
    if has_command zypper; then
      sudo zypper in sassc
    elif has_command apt-get; then
      sudo apt-get install sassc
    elif has_command dnf; then
      sudo dnf install sassc
    elif has_command dnf; then
      sudo dnf install sassc
    elif has_command pacman; then
      sudo pacman -S --noconfirm sassc
    fi
  fi
}

theme_color() {
  if [[ "$theme" != '' ]]; then
    case "$theme" in
      -blue)
        theme_color='blue'
        ;;
      -purple)
        theme_color='purple'
        ;;
      -pink)
        theme_color='pink'
        ;;
      -red)
        theme_color='red'
        ;;
      -orange)
        theme_color='orange'
        ;;
      -yellow)
        theme_color='yellow'
        ;;
      -green)
        theme_color='green'
        ;;
      -grey)
        theme_color='grey'
        ;;
      -cherry)
        theme_color='cherry'
        ;;
    esac
    sed -i "/\$theme:/s/default/${theme_color}/" "${SRC_DIR}/sass/_theme-variant-temp.scss"
  fi
}

gtk4_config() {
  local color="${1}"
  local opacity="${2}"
  local alt="${3}"
  local small="${4}"
  local theme="${5}"

  # For libadwaita
  rm -rf "$HOME/.config/gtk-4.0/"{assets,windows-assets,gtk.css,gtk-dark.css}
  cp -r "${SRC_DIR}/assets/gtk/common-assets/assets"                                         "$HOME/.config/gtk-4.0"

  if [[ ${theme} != '-default' ]]; then
    cp -r "${SRC_DIR}/assets/gtk/common-assets/assets${theme}/"*'.png'                       "$HOME/.config/gtk-4.0/assets"
  fi

  cp -r "${SRC_DIR}/assets/gtk/windows-assets/titlebutton${alt}${small}"                     "$HOME/.config/gtk-4.0/windows-assets"
  sassc $SASSC_OPT "${SRC_DIR}/main/gtk-4.0/gtk${color}${opacity}.scss"                      "$HOME/.config/gtk-4.0/gtk.css"
  sassc $SASSC_OPT "${SRC_DIR}/main/gtk-4.0/gtk-Dark${opacity}.scss"                         "$HOME/.config/gtk-4.0/gtk-dark.css"

  echo; prompt -i "Installed ${THEME_NAME}${color}${opacity}${alt}${small}${theme} theme in $HOME/.config/gtk-4.0"
}

remove_gtk4_config() {
  # For libadwaita
  rm -rf "$HOME/.config/gtk-4.0/"{assets,windows-assets,gtk.css,gtk-dark.css}
}

install_libadwaita() {
  for color in "${colors[@]-${COLOR_VARIANTS[0]}}"; do
    for opacity in "${opacities[@]-${OPACITY_VARIANTS[0]}}"; do
      for alt in "${alts[@]-${ALT_VARIANTS[0]}}"; do
        for small in "${smalls[@]-${SMALL_VARIANTS[0]}}"; do
          for theme in "${themes[@]-${THEME_VARIANTS[0]}}"; do
            gtk4_config "${color}" "${opacity}" "${alt}" "${small}" "${theme}"
          done
        done
      done
    done
  done
}

install_theme() {
  echo
  for color in "${colors[@]-${COLOR_VARIANTS[@]}}"; do
    for opacity in "${opacities[@]-${OPACITY_VARIANTS[@]}}"; do
      for alt in "${alts[@]-${ALT_VARIANTS[@]}}"; do
        for small in "${smalls[@]-${SMALL_VARIANTS[0]}}"; do
          for theme in "${themes[@]-${THEME_VARIANTS[0]}}"; do
            for icon in "${icons[@]-${ICON_VARIANTS[0]}}"; do
              install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}" "${opacity}" "${alt}" "${small}" "${theme}" "${icon}"
            done
          done
        done
      done
    done
  done
}

clean_theme() {
  for color in '-light' '-dark'; do
    for opacity in "${opacities[@]-${OPACITY_VARIANTS[@]}}"; do
      for alt in "${alts[@]-${ALT_VARIANTS[@]}}"; do
        for small in "${smalls[@]-${SMALL_VARIANTS[0]}}"; do
          for theme in "${themes[@]-${THEME_VARIANTS[@]}}"; do
            clean "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}" "${opacity}" "${alt}" "${small}" "${theme}"
          done
        done
      done
    done
  done

  if [[ "$UID" != "$ROOT_UID" ]]; then
    if [[ "$DEST_DIR" == "$HOME/.themes" ]]; then
      local dest="$HOME/.local/share/themes"
    fi

    for color in "${colors[@]-${COLOR_VARIANTS[@]}}"; do
      for opacity in "${opacities[@]-${OPACITY_VARIANTS[@]}}"; do
        for alt in "${alts[@]-${ALT_VARIANTS[@]}}"; do
          for small in "${smalls[@]-${SMALL_VARIANTS[@]}}"; do
            for theme in "${themes[@]-${THEME_VARIANTS[@]}}"; do
              clean "${dest}" "${name:-${THEME_NAME}}" "${color}" "${opacity}" "${alt}" "${small}" "${theme}"
            done
          done
        done
      done
    done
  fi
}

clean_theme

cd "${SRC_DIR}/main/gtk-3.0" && ./make_gresource_xml.sh
cd "${SRC_DIR}/main/gtk-4.0" && ./make_gresource_xml.sh

if [[ "${small:-}" == 'small' ]]; then
  cd ${SRC_DIR}/assets/gtk/windows-assets && ./render-small-assets.sh && ./render-alt-small-assets.sh
fi

if [[ "$(command -v gnome-shell)" ]]; then
  echo; prompt -w "Desktop version: '$(gnome-shell --version)'";
  SHELL_VERSION="$(gnome-shell --version | cut -d ' ' -f 3 | cut -d . -f -1)"
  if [[ "${SHELL_VERSION:-}" -ge "47" ]]; then
    GS_VERSION="47-0"
  elif [[ "${SHELL_VERSION:-}" -ge "46" ]]; then
    GS_VERSION="46-0"
  elif [[ "${SHELL_VERSION:-}" -ge "44" ]]; then
    GS_VERSION="44-0"
  elif [[ "${SHELL_VERSION:-}" -ge "42" ]]; then
    GS_VERSION="42-0"
  elif [[ "${SHELL_VERSION:-}" -ge "40" ]]; then
    GS_VERSION="40-0"
  else
    GS_VERSION="3-28"
  fi
else
  prompt -e "'gnome-shell' not found, using styles for last gnome-shell version available."
  GS_VERSION="47-0"
fi

if [[ "${gdm:-}" != 'true' && "${revert:-}" != 'true' ]]; then
  install_package
  if [[ "${libadwaita:-}" != 'true' ]]; then
    install_theme
  else
    install_libadwaita && install_theme
  fi
fi

if [[ "${gdm:-}" == 'true' && "${revert:-}" != 'true' && "$UID" -eq "$ROOT_UID" ]]; then
  install_package && install_theme && install_gdm "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}" "${opacity}" "${alt}" "${small}" "${theme}" "${icon}"
fi

if [[ "${revert:-}" == 'true' ]]; then
  if [[ "${gdm:-}" != 'true' && "$UID" -eq "$ROOT_UID" ]]; then
    revert_gdm
  else
    remove_gtk4_config
    echo; prompt -i "Removed gtk4.0 configs!"
  fi
fi

echo; prompt -s "Done!"
