# Passed-in variables
LOG=$1
Cyan=$2
White=$3
Red=$4

echo -e "[${Cyan}*${White}] Installing Theme, Icons, and Font..."

# Move those directories, whether they existed or not, to $HOME equivalent directores.
sudo mv -f /usr/share/themes $HOME/.themes
sudo mv -f /usr/share/icons $HOME/.icons
sudo mv -f $HOME/.icons $HOME/.local/share/icons

# Create a symlink between the new paths and old paths
sudo ln -s $HOME/.themes /usr/share/themes
sudo ln -s $HOME/.icons /usr/share/icons
sudo ln -s $HOME/.local/share/icons $HOME/.icons

# Set Flatpaks to have access to those directories, as well as the GTK4 themes in xdg-config.
flatpak override --user --filesystem=$HOME/.themes
flatpak override --user --filesystem=$HOME/.local/share/icons
flatpak override --user --filesystem=xdg-config/gtk-4.0

# Set the GTK Theme and GTK Icons for non-Flatpaks
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme Gruvbox-Material-Dark

# Set the same for Flatpaks
flatpak override --user --env=GTK_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme)
flatpak override --user --env=ICON_THEME=Gruvbox-Material-Dark
# Set QT Flatpaks to use the currently active Kvantum theme
flatpak override --user --env=QT_STYLE_OVERRIDE=kvantum --filesystem=xdg-config/Kvantum:ro
