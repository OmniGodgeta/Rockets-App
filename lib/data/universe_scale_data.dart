/// A single reference point in the Scale of the Universe, sorted ascending
/// by [sizeMeters]. Used by ScaleScreen as the native, ad-free replacement
/// for embedding htwins.net/scale2 (which also serves a Google AdSense
/// banner and is built for desktop mouse/hover interaction, not touch).
class UniverseScaleItem {
  final String name;
  final double sizeMeters;
  final String description;

  const UniverseScaleItem({
    required this.name,
    required this.sizeMeters,
    required this.description,
  });
}

const List<UniverseScaleItem> universeScaleData = [
  UniverseScaleItem(
      name: 'Planck length',
      sizeMeters: 1.6e-35,
      description:
          'The smallest length that has physical meaning - below this, our current understanding of spacetime breaks down.'),
  UniverseScaleItem(
      name: 'String (hypothetical)',
      sizeMeters: 1.0e-34,
      description:
          'In string theory, the fundamental strings whose vibrations may give rise to every particle.'),
  UniverseScaleItem(
      name: 'Quark',
      sizeMeters: 1.0e-19,
      description:
          'A fundamental particle - as far as we can measure, quarks have no size at all.'),
  UniverseScaleItem(
      name: 'Electron',
      sizeMeters: 2.8e-15,
      description:
          'A fundamental particle that orbits the nucleus of every atom.'),
  UniverseScaleItem(
      name: 'Proton',
      sizeMeters: 1.7e-15,
      description:
          'One of the particles that make up an atomic nucleus, built from three quarks.'),
  UniverseScaleItem(
      name: 'Atomic nucleus (uranium)',
      sizeMeters: 1.5e-14,
      description:
          'The dense core of an atom, containing nearly all of its mass.'),
  UniverseScaleItem(
      name: 'Hydrogen atom',
      sizeMeters: 1.06e-10,
      description: 'The simplest and most abundant element in the universe.'),
  UniverseScaleItem(
      name: 'DNA width',
      sizeMeters: 2.0e-9,
      description:
          'The double helix that encodes the genetic instructions for every living thing.'),
  UniverseScaleItem(
      name: 'Ribosome',
      sizeMeters: 2.5e-8,
      description:
          'The molecular machine inside cells that builds proteins from RNA instructions.'),
  UniverseScaleItem(
      name: 'HIV virus',
      sizeMeters: 1.2e-7,
      description:
          'One of the smallest viruses, roughly 100x smaller than a typical bacterium.'),
  UniverseScaleItem(
      name: 'Red blood cell',
      sizeMeters: 7.5e-6,
      description:
          'Carries oxygen through your bloodstream - about 5 million fit on a pinhead.'),
  UniverseScaleItem(
      name: 'Human hair width',
      sizeMeters: 7.0e-5,
      description: 'About as thin as anything the naked eye can resolve.'),
  UniverseScaleItem(
      name: 'Grain of sand',
      sizeMeters: 5.0e-4,
      description: 'A typical fine grain of beach sand.'),
  UniverseScaleItem(
      name: 'Ant',
      sizeMeters: 5.0e-3,
      description: 'A common household ant, nose to tail.'),
  UniverseScaleItem(
      name: 'Housefly',
      sizeMeters: 8.0e-3,
      description: 'A typical adult housefly.'),
  UniverseScaleItem(
      name: 'Golf ball',
      sizeMeters: 4.3e-2,
      description: 'A standard regulation golf ball.'),
  UniverseScaleItem(
      name: 'Human hand',
      sizeMeters: 1.8e-1,
      description: 'An adult human hand, wrist to fingertip.'),
  UniverseScaleItem(
      name: 'Human being',
      sizeMeters: 1.7,
      description: 'The average height of an adult human.'),
  UniverseScaleItem(
      name: 'Giraffe',
      sizeMeters: 5.5,
      description: 'The tallest living land animal.'),
  UniverseScaleItem(
      name: 'Falcon 9 rocket',
      sizeMeters: 70.0,
      description: 'SpaceX\'s workhorse orbital rocket, standing on the pad.'),
  UniverseScaleItem(
      name: 'Statue of Liberty',
      sizeMeters: 93.0,
      description:
          'Pedestal to torch, one of the most recognizable statues on Earth.'),
  UniverseScaleItem(
      name: 'Eiffel Tower',
      sizeMeters: 330.0,
      description: 'The iron lattice tower in Paris, France.'),
  UniverseScaleItem(
      name: 'Burj Khalifa',
      sizeMeters: 828.0,
      description: 'The tallest human-made structure on Earth.'),
  UniverseScaleItem(
      name: 'Central Park',
      sizeMeters: 4000.0,
      description: 'The length of Central Park in New York City.'),
  UniverseScaleItem(
      name: 'Mount Everest',
      sizeMeters: 8849.0,
      description: 'The tallest mountain above sea level on Earth.'),
  UniverseScaleItem(
      name: 'International Space Station orbit altitude',
      sizeMeters: 4.0e5,
      description: 'How high the ISS orbits above the Earth\'s surface.'),
  UniverseScaleItem(
      name: 'English Channel width',
      sizeMeters: 3.4e4,
      description: 'The narrowest crossing between England and France.'),
  UniverseScaleItem(
      name: 'Earth diameter',
      sizeMeters: 1.27e7,
      description: 'Our home planet, pole to pole is slightly less.'),
  UniverseScaleItem(
      name: 'Moon diameter',
      sizeMeters: 3.47e6,
      description: 'Earth\'s only natural satellite.'),
  UniverseScaleItem(
      name: 'Earth-Moon distance',
      sizeMeters: 3.84e8,
      description: 'The average distance between Earth and the Moon.'),
  UniverseScaleItem(
      name: 'Sun diameter',
      sizeMeters: 1.39e9,
      description: 'About 109 Earths could fit across the Sun\'s face.'),
  UniverseScaleItem(
      name: 'Earth-Sun distance (1 AU)',
      sizeMeters: 1.496e11,
      description:
          'One Astronomical Unit - the standard yardstick for distances in the solar system.'),
  UniverseScaleItem(
      name: 'Jupiter orbit',
      sizeMeters: 1.5e12,
      description: 'The diameter of Jupiter\'s orbit around the Sun.'),
  UniverseScaleItem(
      name: 'Neptune orbit',
      sizeMeters: 9.0e12,
      description:
          'The diameter of Neptune\'s orbit, the outermost major planet.'),
  UniverseScaleItem(
      name: 'Heliosphere',
      sizeMeters: 3.7e13,
      description:
          'The bubble of solar wind that surrounds our entire solar system.'),
  UniverseScaleItem(
      name: 'Light-year',
      sizeMeters: 9.461e15,
      description:
          'The distance light travels in one year - the basic yardstick for interstellar distances.'),
  UniverseScaleItem(
      name: 'Oort Cloud outer edge',
      sizeMeters: 1.5e16,
      description:
          'The distant shell of icy bodies thought to surround the solar system.'),
  UniverseScaleItem(
      name: 'Distance to Proxima Centauri',
      sizeMeters: 4.0e16,
      description: 'The nearest star to our Sun, about 4.24 light-years away.'),
  UniverseScaleItem(
      name: 'Milky Way (thickness)',
      sizeMeters: 3.0e18,
      description: 'The thickness of our galaxy\'s spiral disk.'),
  UniverseScaleItem(
      name: 'Milky Way diameter',
      sizeMeters: 9.5e20,
      description: 'Our home galaxy, containing 100-400 billion stars.'),
  UniverseScaleItem(
      name: 'Distance to Andromeda Galaxy',
      sizeMeters: 2.4e22,
      description:
          'The nearest large galaxy to the Milky Way, on a collision course in ~4.5 billion years.'),
  UniverseScaleItem(
      name: 'Local Group of galaxies',
      sizeMeters: 9.5e22,
      description:
          'The cluster of 80+ galaxies that includes the Milky Way and Andromeda.'),
  UniverseScaleItem(
      name: 'Virgo Supercluster',
      sizeMeters: 1.0e24,
      description:
          'The supercluster of galaxy groups that contains our Local Group.'),
  UniverseScaleItem(
      name: 'Observable universe diameter',
      sizeMeters: 8.8e26,
      description:
          'The full extent of the universe we can observe - everything whose light has had time to reach us.'),
];
