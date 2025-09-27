# AllPlayed - Addon World of Warcraft

![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)
![Interface](https://img.shields.io/badge/interface-11.0.7-green.svg)
![License](https://img.shields.io/badge/license-MIT-yellow.svg)

**AllPlayed** est un addon World of Warcraft qui suit et affiche le temps de jeu de tous vos personnages avec une interface graphique moderne et des statistiques détaillées.

## 🎯 Fonctionnalités

### ⭐ **Suivi automatique**
- Enregistrement automatique du temps de jeu à chaque connexion
- Sauvegarde persistante entre les sessions
- Données organisées par serveur/royaume
- Informations complètes : nom, classe, niveau, temps total

### 📊 **Statistiques détaillées**
- **Temps de session** : Temps depuis votre connexion actuelle
- **Temps personnage** : Temps total du personnage actuel
- **Temps global** : Temps cumulé de tous vos personnages
- Affichage avec couleurs de classe
- Tri intelligent (personnage actuel en premier)

### 🎮 **Barre de temps interactive**
- Barre flottante redimensionnable et déplaçable
- 4 modes d'affichage au choix
- Mise à jour en temps réel (toutes les secondes)
- Menu contextuel avec options avancées
- Tooltip informatif au survol

## 📦 Installation

### Méthode manuelle
1. Téléchargez les fichiers de l'addon
2. Copiez le dossier `AllPlayed` dans :
   ```
   World of Warcraft\_retail_\Interface\AddOns\
   ```
3. Structure finale :
   ```
   AllPlayed/
   ├── AllPlayed.toc
   ├── AllPlayed.lua
   └── AllPlayedBar.lua
   ```
4. Redémarrez World of Warcraft
5. Activez l'addon dans l'écran de sélection des personnages

### Vérification
Après connexion, vous devriez voir dans le chat :
```
[AllPlayed] Addon chargé. Utilisez /aplayed pour voir vos statistiques.
[AllPlayed] Utilisez /aplayed bar pour afficher/masquer la barre de temps.
```

## 🎮 Utilisation

### Commandes principales

| Commande | Description |
|----------|-------------|
| `/aplayed` | Affiche les statistiques complètes |
| `/aplayed help` | Affiche l'aide complète |
| `/aplayed update` | Met à jour manuellement le temps de jeu |
| `/aplayed session` | Affiche le temps de session dans le chat |

### Commandes de débogage

| Commande | Description |
|----------|-------------|
| `/aplayed debug` | Affiche les informations de diagnostic |
| `/aplayed force` | Force l'affichage de la barre (test) |

### Commandes de la barre

| Commande | Description |
|----------|-------------|
| `/aplayed bar` | Affiche/masque la barre de temps |
| `/aplayed bar show` | Affiche la barre de temps |
| `/aplayed bar hide` | Masque la barre de temps |
| `/aplayed bar reset` | Recentre la barre au milieu de l'écran |

## 🎛️ Barre de temps interactive

### Contrôles
- **Clic gauche + glisser** : Déplacer la barre
- **Clic droit** : Menu contextuel avec options
- **Coin bas-droit** : Poignée pour redimensionner
- **Survol** : Tooltip avec détails complets

### Modes d'affichage

#### 1. Mode Complet (par défaut)
```
Session: 1h 23m 45s
Perso: 15h 42m 30s
Global: 127h 15m 12s
```

#### 2. Session uniquement
```
Session: 1h 23m 45s
```

#### 3. Personnage uniquement
```
Gandalf: 15h 42m 30s
```

#### 4. Global uniquement
```
Global: 127h 15m 12s
```

### Menu contextuel (clic droit)
- **Mode d'affichage** : Choisir entre les 4 modes
- **Réinitialiser session** : Remet le compteur de session à zéro
- **Masquer la barre** : Cache la barre
- **Recentrer la barre** : Remet la barre au centre de l'écran (0,0)

## 📊 Exemple d'utilisation

### Affichage des statistiques
```
/aplayed
```

Résultat dans le chat :
```
=== AllPlayed - Statistiques ===
[ACTUEL] Gandalf (Mage 80) - 45h 23m 12s
--- Autres personnages ---
Legolas (Chasseur 75) - 32h 15m 8s
Gimli (Guerrier 70) - 28h 45m 22s
Aragorn (Paladin 78) - 41h 12m 35s
--- Résumé ---
Total sur 4 personnage(s): 147h 36m 17s
```

### Barre de temps
1. **Première activation** : `/aplayed bar`
2. **Personnalisation** : Déplacez et redimensionnez selon vos préférences
3. **Changement de mode** : Clic droit → sélectionner le mode souhaité
4. **Tooltip** : Survolez pour voir tous les détails

## ⚙️ Configuration

### Paramètres sauvegardés automatiquement
- Position et taille de la barre
- Mode d'affichage sélectionné
- Visibilité de la barre
- Données de temps de jeu de tous les personnages

### Réinitialisation
Pour réinitialiser complètement l'addon :
1. Fermez WoW
2. Supprimez le fichier `AllPlayed.lua.bak` dans le dossier WTF
3. Relancez WoW

## 🎨 Personnalisation

### Taille de la barre
- **Taille minimale** : 100x20 pixels
- **Taille maximale** : 500x100 pixels
- **Taille par défaut** : 300x60 pixels

### Couleurs
- **Texte** : Blanc avec contour noir
- **Arrière-plan** : Noir semi-transparent (80%)
- **Bordure** : Gris moyen
- **Classes** : Couleurs officielles WoW

## 🐛 Résolution de problèmes

### L'addon ne se charge pas
1. Vérifiez que les fichiers sont dans le bon dossier
2. Assurez-vous que l'addon est activé dans l'interface
3. Vérifiez la compatibilité de la version d'interface dans le fichier .toc

### La barre n'apparaît pas
1. Utilisez `/aplayed bar show`
2. Recentrez la barre : `/aplayed bar reset` (centre à la position 0,0)
3. Vérifiez si elle n'est pas hors écran avec le menu contextuel

### La barre est vide/affiche des zéros
1. Attendez 2-3 secondes après la connexion (temps de chargement des données)
2. Utilisez `/aplayed update` pour forcer la récupération des données
3. Déconnectez-vous et reconnectez-vous pour réinitialiser l'addon
4. La barre se mettra à jour automatiquement une fois les données chargées

### La barre ne s'affiche plus du tout
1. **Recentrage rapide** : `/aplayed bar reset` pour la remettre au centre
2. **Test de diagnostic** : `/aplayed debug` pour vérifier les modules chargés
3. **Force l'affichage** : `/aplayed force` pour tester la création de la barre
4. **Recharge complète** : Tapez `/reload` dans le chat pour recharger l'interface
5. **Vérifiez les erreurs** : Ouvrez la console d'erreurs avec `/console scriptErrors 1`
6. **Réinstallation** : Si rien ne fonctionne, supprimez et réinstallez l'addon

### Données manquantes
1. Utilisez `/aplayed update` pour forcer la mise à jour
2. Connectez-vous sur chaque personnage au moins une fois

### Erreurs dans le chat
- **"Module barre non disponible"** : Le fichier AllPlayedBar.lua n'est pas chargé
- **"Aucune donnée trouvée"** : Aucun personnage enregistré sur ce serveur

## 📋 Notes techniques

### Compatibilité
- **Version WoW** : 11.0.7 (The War Within)
- **Type** : Retail uniquement
- **Dépendances** : Aucune

### APIs utilisées
- `RequestTimePlayed()` et `TIME_PLAYED_MSG` pour les données officielles
- `SavedVariables` pour la persistance des données
- Interface graphique native WoW

### Performance
- **Impact CPU** : Minimal (mise à jour 1x/seconde quand visible)
- **Mémoire** : Très faible (~50KB avec données de 20 personnages)
- **Réseau** : Aucun trafic réseau

## 🔄 Changelog

### Version 1.1.0
- ➕ Ajout de la barre de temps interactive
- ➕ Suivi du temps de session
- ➕ 4 modes d'affichage
- ➕ Menu contextuel avec options
- ➕ Tooltip informatif
- 🔧 Interface graphique redimensionnable
- 🔧 Sauvegarde automatique des préférences

### Version 1.0.0
- 🎉 Version initiale
- ➕ Suivi automatique du temps de jeu
- ➕ Commande `/aplayed` avec statistiques
- ➕ Sauvegarde par serveur/personnage
- ➕ Couleurs de classe

## 📝 Licence

Ce projet est sous licence MIT. Vous êtes libre de l'utiliser, le modifier et le distribuer.

## 👨‍💻 Auteur

**TonTon** - Développeur passionné de World of Warcraft

---

*Pour toute question, suggestion ou bug report, n'hésitez pas à me contacter !*

## 🚀 Utilisation rapide

1. **Installation** : Copiez les fichiers dans `Interface\AddOns\AllPlayed\`
2. **Première utilisation** : `/aplayed` pour voir vos stats
3. **Barre de temps** : `/aplayed bar` pour l'afficher
4. **Si barre invisible** : `/aplayed bar reset` pour la recentrer
5. **Personnalisation** : Clic droit sur la barre pour les options
6. **Aide** : `/aplayed help` pour toutes les commandes

**Bon jeu ! 🎮**
