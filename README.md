# Evalbot - Robot Cartographe Autonome

Auteurs : Clément CARREIRA & Alexis BERNARD

Contexte : Projet de d'Architecture (E3-FI S1) - Programmation en Assembleur ARM Cortex-M3.

## Description du Projet

Ce projet implémente un système de navigation et de cartographie autonome sur la plateforme Stellaris Evalbot. Le programme est conçu pour permettre au robot d'explorer un environnement inconnu, de mémoriser son parcours (distances et virages) dans la RAM, et de le restituer fidèlement sur commande.

Le fonctionnement se décompose en deux phases distinctes : l'Exploration (enregistrement) et la Restitution (rejeu).

## Fonctionnement

### 1. Phase d'Exploration (Acquisition)

Le robot navigue en autonomie et cartographie son environnement en temps réel :

- Navigation : Le robot avance en ligne droite par défaut.

- Détection d'obstacles : Lorsqu'un bumper est activé par une collision :

  - Bumper Droit : Le robot recule et effectue un virage à gauche.

  - Bumper Gauche : Le robot recule et effectue un virage à droite.

- Mémorisation : À chaque événement (collision/virage), le robot enregistre en mémoire :

- La distance parcourue (temps CPU écoulé depuis le dernier événement).

- La direction du virage effectué.

Contraintes : La capacité de mémorisation est limitée à 200 segments (virages).

Arrêt : Une pression sur le Switch 1 arrête l'exploration et sauvegarde le dernier segment rectiligne en mémoire.

### 2. Phase de Restitution (Rejeu)

Déclenchée par le Switch 2, cette phase consiste à relire la mémoire pour reproduire le parcours exact :

- Lecture Mémoire : Le robot parcourt séquentiellement les données enregistrées en RAM (4 octets par action).

- Synchronisation Temporelle : Il avance tout droit en décrémentant un compteur correspondant à la distance enregistrée.

- Action : Lorsque le compteur atteint 0, le robot effectue le virage mémorisé.

- Fin de cycle : Le processus se répète jusqu'à ce que le pointeur de lecture atteigne la fin des données enregistrées.

## Architecture Technique

- Langage : Assembleur ARM Cortex M3.

- Matériel : Kit Stellaris Evalbot (Microcontrôleur LM3S9B92).

Périphériques utilisés :

- GPIO Port E : Bumpers (Entrées avec Pull-Up).

- GPIO Port D : Switchs (Entrées) et contrôle Moteurs.

- GPIO Port F : LEDs (Signalisation d'état).

- Timers/PWM : Gestion de la vitesse des moteurs.

## Utilisation

- Démarrage : Allumer le robot.

- Lancer l'Exploration : Le robot démarre automatiquement (ou via une commande initiale selon configuration).

- Stopper l'Exploration : Appuyer sur Switch 1.

- Lancer le Rejeu : Appuyer sur Switch 2.

> Projet réalisé dans le cadre de la formation ingénieur ESIEE Paris.
