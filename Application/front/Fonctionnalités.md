# But

Le but de ce document est de décrire les diverses fonctionnalités pour lesquelles la faisabilité doit être testée. Cela permettra de s'assurer que l'ensemble de celles-ci sont réalisables avec la technologie front end choisie.

# Technologie choisie

Après moult débats, la technologie choisie est Flutter. Plus précisément, le choix s'est porté sur Bonfire, une surcouche du game engine Flame, créé spécialement pour Flutter. Celui-ci se spécialise dans la création de jeux RPG, en vue de côté ou dessus, et possède notamment une multitude de méthodes et abstractions (ennemis, combat, gestion de l'éclairage, etc). L'utilisation de ce package est idéale pour notre application, qui tombe parfaitement dans les cibles prévues. 

# Liste des fonctionnalités : overview

| # | Fonctionnalité | Testé |
| --- | --- |--- |
| 1 | Sprites animés | ✓ |
| 2 | Joystick (bouger) | ✓ |
| 3 | Musique de fond | ✓ |
| 4 | Sons en fonction d'actions | ✓ |
| 5 | Changement de sprite en fonction de la direction / autre | ✓ |
| 6 | Système de combat | ✓ | 
| 7 | Système d'ennemis + spawn | ✓ | 
| 8 | Interaction avec des objets (statiques) | ✓ | 
| 9 | Interaction avec des PNJ | ✓ | 
| 10 | Interactions poussées (drag and drop) | ✗✗ |
| 11 | Affichage d'un menu complexe (dynamique) | ✓ | 
| 12 | Import / création d'une map / objets | ✓ |
| 13 | Permettre au joueur de se déplacer librement dans un environnement fini (village) | ✓ | 
| 14 | Système de caméra (centrée sur le joueur) | ✓ | 
| 15 | Physique (collisions) | ✓ | 
| 16 | Dialogues | ✓ | 
| 17 | **NEW** Action supplémentaire (joystick) possible ou non en fonction des objets proches | ✓ | 
| 18 | **B** Changement de vue (passage d'un mode RPG à construction) | ✗✗ | 
| 19 | **B** Changement d'assets dynamique (entrer dans une maison par exemple) | ✓ | 
| 20 | **IMPORTANT** : tester le multijoueur (intégration avec le game engine) | ✓ |

**B** : fonctionnalité bonus, non essentielle.

## 1. Sprites animés
> Multiples possibilités offertes directement par Bonfire. Voir par exemple player.dart dans utils/spriteSheets.

## 2. Joystick (bouger)
> Joystick directement fourni par Bonfire. Voir main.dart. Il fonctionne en conjonction avec la classe player (ici : Knight).

## 3. Musique de fond
> Utilisation du package flame_audio. Possibilité de mettre une musique de fond ou encore des sons en cache. Voir la classe utilitaire Sounds. 

## 4. Sons en fonction d'action
> Utilisation du système de caching de flame_audio. Voir la classe utilitaire Sounds. 

## 5. Changement de sprite en fonction de la direction / autre
> Directement géré par Bonfire si on étend la classe SimplePlayer et qu'on lui donne les bonnes spriteSheets.

## 6. Système de combat
> Directement intégré par Bonfire. Le joueur doit hériter de SimplePlayer, lui offrant moult méthodes qu'il est possible de redéfinir. Les ennemis doivent hériter de SimpleEnemy. Voir exemple (simple) dans main.dart (classe Knight) et imp.dart. 

## 7. Système d'ennemis + spawn
> Possibilité de créer des ennemis au comportement rudimentaire en héritant de la classe SimpleEnemy. Pour le faire spawn, il suffit de l'ajouter au jeu (gameRef.add()). Voir exemple dans imp.dart.

## 8. Interaction avec des objets (statiques)
> Utilisation d'une mixin offerte par Bonfire (TapGesture). Voir exemple dans sign.dart.

## 9. Interaction avec des PNJ
> Plusieurs possibilités : TapGesture, quand on se rapproche assez, ... Voir classe Wizard pour un exemple de la dernière possibilité.

## 10. Interactions poussées (drag and drop)
> Bonfire prévoit une mixin pour répondre à ce problème (Draggable). Cepandant, l'objet déplacé ne voit pas ses collisions checkées pendant que le joueur déplace l'objet et le code semble peu ouvert pour permettre d'arriver à un résultat satisfaisant. De ce fait, cette fonctionnalité a été mise de côté et le jeu adapté.

## 11. Affichage d'un menu complexe (dynamique)
> Prévu dans Bonfire. Il suffit d'ajouter un overlay au jeu. Voir exemple dans sign.dart.

## 12. Import / création d'une map / objets
> Bonfire permet d'importer une map créée depuis l'outil Tiled. Il permet aussi de mapper à des classes Dart les différents tags associés à la map.

## 13. Permettre au joueur de se déplacer librement dans un environnement fini (village)
> But recherché par ce test. Le joueur peut se déplacer dans une map importée grâce au joystick et est bien bloqué à l'intérieur (collisions).

## 14. Système de caméra (centrée sur le joueur)
> Bonfire offre une caméra. Celle-ci peut suivre le joueur, ou encore se déplacer vers un élément précis. Elle est configurable de plusieurs manières. Voir main.dart.

## 15. Physique (collisions)
> Bonfire offre une collision à la map lors de l'import. Pour les autres objets rajoutés par la suite, il suffit d'ajouter la mixin ObjectCollision. Voir exemple dans main.dart (Knight).

## 16. Dialogues
> Intégrés dans Bonfire (TalkDialog). Voir exemple dans la classe Wizard (méthode _showIntroduction).

## 17. Action supplémentaire (joystick) possible ou non en fonction des objets proches
> Utilisation de la fonction seeComponentType<T>. Exemple dans main.dart.

## 18. Changement de vue (passage d'un mode RPG à construction)
> Non nécessaire au vu des choix effectués.

## 19. Changement d'assets dynamique (entrer dans une maison par exemple)
> Voir exemple ici : https://github.com/RafaelBarbosatec/multi-biome

## 20. Tester le multijoueur (intégration avec le game engine)
> Voir https://github.com/RafaelBarbosatec/mountain_fight.
