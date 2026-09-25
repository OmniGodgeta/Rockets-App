/// A single reference point in the Scale of the Universe, sorted ascending
/// by [sizeMeters]. Used by ScaleScreen as the native, ad-free replacement
/// for embedding htwins.net/scale2 (which also serves a Google AdSense
/// banner and is built for desktop mouse/hover interaction, not touch).
///
/// [wikipediaTitle] is a verified (2026-09-25) English Wikipedia article
/// title, used to fetch a real reference photo at runtime via
/// https://en.wikipedia.org/api/rest_v1/page/summary/<title> - a live API
/// call, not a hardcoded image URL.
class UniverseScaleItem {
  final String name;
  final double sizeMeters;
  final String description;
  final String wikipediaTitle;

  const UniverseScaleItem({
    required this.name,
    required this.sizeMeters,
    required this.description,
    required this.wikipediaTitle,
  });
}

const List<UniverseScaleItem> universeScaleData = [
  UniverseScaleItem(
      name: 'Planck length', sizeMeters: 1.6e-35, wikipediaTitle: 'Planck_length',
      description: 'The smallest length that has physical meaning - below this, our current understanding of spacetime breaks down.'),
  UniverseScaleItem(
      name: 'String (hypothetical)', sizeMeters: 1e-34, wikipediaTitle: 'String_theory',
      description: 'In string theory, the fundamental strings whose vibrations may give rise to every particle.'),
  UniverseScaleItem(
      name: 'Quark', sizeMeters: 1e-19, wikipediaTitle: 'Quark',
      description: 'A fundamental particle - as far as we can measure, quarks have no size at all.'),
  UniverseScaleItem(
      name: 'Proton', sizeMeters: 1.7e-15, wikipediaTitle: 'Proton',
      description: 'One of the particles that make up an atomic nucleus, built from three quarks.'),
  UniverseScaleItem(
      name: 'Electron', sizeMeters: 2.8e-15, wikipediaTitle: 'Electron',
      description: 'A fundamental particle that orbits the nucleus of every atom.'),
  UniverseScaleItem(
      name: 'Atomic nucleus (uranium)', sizeMeters: 1.5e-14, wikipediaTitle: 'Atomic_nucleus',
      description: 'The dense core of an atom, containing nearly all of its mass.'),
  UniverseScaleItem(
      name: 'Hydrogen atom', sizeMeters: 1.06e-10, wikipediaTitle: 'Hydrogen_atom',
      description: 'The simplest and most abundant element in the universe.'),
  UniverseScaleItem(
      name: 'DNA width', sizeMeters: 2e-9, wikipediaTitle: 'DNA',
      description: 'The double helix that encodes the genetic instructions for every living thing.'),
  UniverseScaleItem(
      name: 'Ribosome', sizeMeters: 2.5e-8, wikipediaTitle: 'Ribosome',
      description: 'The molecular machine inside cells that builds proteins from RNA instructions.'),
  UniverseScaleItem(
      name: 'HIV virus', sizeMeters: 1.2e-7, wikipediaTitle: 'HIV',
      description: 'One of the smallest viruses, roughly 100x smaller than a typical bacterium.'),
  UniverseScaleItem(
      name: 'Red blood cell', sizeMeters: 7.5e-6, wikipediaTitle: 'Red_blood_cell',
      description: 'Carries oxygen through your bloodstream - about 5 million fit on a pinhead.'),
  UniverseScaleItem(
      name: 'Human hair width', sizeMeters: 7e-5, wikipediaTitle: 'Hair',
      description: 'About as thin as anything the naked eye can resolve.'),
  UniverseScaleItem(
      name: 'Grain of sand', sizeMeters: 0.0005, wikipediaTitle: 'Sand',
      description: 'A typical fine grain of beach sand.'),
  UniverseScaleItem(
      name: 'Ant', sizeMeters: 0.005, wikipediaTitle: 'Ant',
      description: 'A common household ant, nose to tail.'),
  UniverseScaleItem(
      name: 'Housefly', sizeMeters: 0.008, wikipediaTitle: 'Housefly',
      description: 'A typical adult housefly.'),
  UniverseScaleItem(
      name: 'Golf ball', sizeMeters: 0.043, wikipediaTitle: 'Golf_ball',
      description: 'A standard regulation golf ball.'),
  UniverseScaleItem(
      name: 'Human hand', sizeMeters: 0.18, wikipediaTitle: 'Hand',
      description: 'An adult human hand, wrist to fingertip.'),
  UniverseScaleItem(
      name: 'Human being', sizeMeters: 1.7, wikipediaTitle: 'Human',
      description: 'The average height of an adult human.'),
  UniverseScaleItem(
      name: 'Giraffe', sizeMeters: 5.5, wikipediaTitle: 'Giraffe',
      description: 'The tallest living land animal.'),
  UniverseScaleItem(
      name: 'Falcon 9 rocket', sizeMeters: 70.0, wikipediaTitle: 'Falcon_9',
      description: "SpaceX's workhorse orbital rocket, standing on the pad."),
  UniverseScaleItem(
      name: 'Statue of Liberty', sizeMeters: 93.0, wikipediaTitle: 'Statue_of_Liberty',
      description: 'Pedestal to torch, one of the most recognizable statues on Earth.'),
  UniverseScaleItem(
      name: 'Eiffel Tower', sizeMeters: 330.0, wikipediaTitle: 'Eiffel_Tower',
      description: 'The iron lattice tower in Paris, France.'),
  UniverseScaleItem(
      name: 'Asteroid Bennu', sizeMeters: 490.0, wikipediaTitle: '101955_Bennu',
      description: 'A near-Earth asteroid about 490 m across - small enough that its own gravity barely holds it together.'),
  UniverseScaleItem(
      name: 'Burj Khalifa', sizeMeters: 828.0, wikipediaTitle: 'Burj_Khalifa',
      description: 'The tallest human-made structure on Earth.'),
  UniverseScaleItem(
      name: 'Central Park', sizeMeters: 4000.0, wikipediaTitle: 'Central_Park',
      description: 'The length of Central Park in New York City.'),
  UniverseScaleItem(
      name: 'Mount Everest', sizeMeters: 8849.0, wikipediaTitle: 'Mount_Everest',
      description: 'The tallest mountain above sea level on Earth.'),
  UniverseScaleItem(
      name: 'English Channel width', sizeMeters: 34000.0, wikipediaTitle: 'English_Channel',
      description: 'The narrowest crossing between England and France.'),
  UniverseScaleItem(
      name: 'Stellar black hole (Cygnus X-1)', sizeMeters: 124000.0, wikipediaTitle: 'Cygnus_X-1',
      description: 'A ~21-solar-mass black hole - its event horizon is only about 124 km across despite outweighing 21 Suns.'),
  UniverseScaleItem(
      name: 'International Space Station orbit altitude', sizeMeters: 400000.0, wikipediaTitle: 'International_Space_Station',
      description: "How high the ISS orbits above the Earth's surface."),
  UniverseScaleItem(
      name: 'Ceres (dwarf planet)', sizeMeters: 940000.0, wikipediaTitle: 'Ceres_(dwarf_planet)',
      description: 'The largest object in the asteroid belt, about 940 km across - big enough to be round under its own gravity.'),
  UniverseScaleItem(
      name: 'Moon diameter', sizeMeters: 3470000.0, wikipediaTitle: 'Moon',
      description: "Earth's only natural satellite."),
  UniverseScaleItem(
      name: 'Mercury diameter', sizeMeters: 4879000.0, wikipediaTitle: 'Mercury_(planet)',
      description: 'The smallest and innermost planet.'),
  UniverseScaleItem(
      name: 'Mars diameter', sizeMeters: 6779000.0, wikipediaTitle: 'Mars',
      description: "The Red Planet, about half Earth's diameter."),
  UniverseScaleItem(
      name: 'White dwarf (Sirius B)', sizeMeters: 12000000.0, wikipediaTitle: 'Sirius_B',
      description: "The collapsed core of a dead star, packing about a Sun's worth of mass into an Earth-sized ball."),
  UniverseScaleItem(
      name: 'Earth diameter', sizeMeters: 12700000.0, wikipediaTitle: 'Earth',
      description: 'Our home planet, pole to pole is slightly less.'),
  UniverseScaleItem(
      name: 'Neptune diameter', sizeMeters: 49244000.0, wikipediaTitle: 'Neptune',
      description: "The outermost major planet, almost 4x Earth's diameter."),
  UniverseScaleItem(
      name: 'Saturn diameter', sizeMeters: 116460000.0, wikipediaTitle: 'Saturn',
      description: 'The ringed giant, second-largest planet in the solar system.'),
  UniverseScaleItem(
      name: 'Jupiter diameter', sizeMeters: 139820000.0, wikipediaTitle: 'Jupiter',
      description: 'The largest planet in the solar system - about 11 Earths could fit across it.'),
  UniverseScaleItem(
      name: 'Earth-Moon distance', sizeMeters: 384000000.0, wikipediaTitle: 'Moon',
      description: 'The average distance between Earth and the Moon.'),
  UniverseScaleItem(
      name: 'Sun diameter', sizeMeters: 1390000000.0, wikipediaTitle: 'Sun',
      description: "About 109 Earths could fit across the Sun's face."),
  UniverseScaleItem(
      name: 'Sagittarius A* (supermassive black hole)', sizeMeters: 24400000000.0, wikipediaTitle: 'Sagittarius_A*',
      description: "The Milky Way's central supermassive black hole - its event horizon is about 24 million km across."),
  UniverseScaleItem(
      name: 'Earth-Sun distance (1 AU)', sizeMeters: 149600000000.0, wikipediaTitle: 'Astronomical_unit',
      description: 'One Astronomical Unit - the standard yardstick for distances in the solar system.'),
  UniverseScaleItem(
      name: 'Jupiter orbit', sizeMeters: 1500000000000.0, wikipediaTitle: 'Jupiter',
      description: "The diameter of Jupiter's orbit around the Sun."),
  UniverseScaleItem(
      name: 'UY Scuti', sizeMeters: 2377000000000.0, wikipediaTitle: 'UY_Scuti',
      description: 'One of the largest known stars by radius - if it replaced the Sun, it would engulf the orbit of Jupiter.'),
  UniverseScaleItem(
      name: 'Neptune orbit', sizeMeters: 9000000000000.0, wikipediaTitle: 'Neptune',
      description: "The diameter of Neptune's orbit, the outermost major planet."),
  UniverseScaleItem(
      name: 'Heliosphere', sizeMeters: 37000000000000.0, wikipediaTitle: 'Heliosphere',
      description: 'The bubble of solar wind that surrounds our entire solar system.'),
  UniverseScaleItem(
      name: 'Messier 87 black hole', sizeMeters: 38350000000000.0, wikipediaTitle: 'Messier_87',
      description: 'The first black hole ever imaged - its event horizon alone is bigger than our entire solar system.'),
  UniverseScaleItem(
      name: 'Light-year', sizeMeters: 9461000000000000.0, wikipediaTitle: 'Light-year',
      description: 'The distance light travels in one year - the basic yardstick for interstellar distances.'),
  UniverseScaleItem(
      name: 'Oort Cloud outer edge', sizeMeters: 1.5e16, wikipediaTitle: 'Oort_cloud',
      description: 'The distant shell of icy bodies thought to surround the solar system.'),
  UniverseScaleItem(
      name: 'Distance to Proxima Centauri', sizeMeters: 4e16, wikipediaTitle: 'Proxima_Centauri',
      description: 'The nearest star to our Sun, about 4.24 light-years away.'),
  UniverseScaleItem(
      name: 'Milky Way (thickness)', sizeMeters: 3e18, wikipediaTitle: 'Milky_Way',
      description: "The thickness of our galaxy's spiral disk."),
  UniverseScaleItem(
      name: 'Small Magellanic Cloud (dwarf galaxy)', sizeMeters: 6.62e19, wikipediaTitle: 'Small_Magellanic_Cloud',
      description: 'A small satellite galaxy of the Milky Way, only about 7,000 light-years across.'),
  UniverseScaleItem(
      name: 'Milky Way diameter', sizeMeters: 9.5e20, wikipediaTitle: 'Milky_Way',
      description: 'Our home galaxy, containing 100-400 billion stars.'),
  UniverseScaleItem(
      name: 'Distance to Andromeda Galaxy', sizeMeters: 2.4e22, wikipediaTitle: 'Andromeda_Galaxy',
      description: 'The nearest large galaxy to the Milky Way, on a collision course in ~4.5 billion years.'),
  UniverseScaleItem(
      name: 'Local Group of galaxies', sizeMeters: 9.5e22, wikipediaTitle: 'Local_Group',
      description: 'The cluster of 80+ galaxies that includes the Milky Way and Andromeda.'),
  UniverseScaleItem(
      name: 'Virgo Supercluster', sizeMeters: 1e24, wikipediaTitle: 'Virgo_Supercluster',
      description: 'The supercluster of galaxy groups that contains our Local Group.'),
  UniverseScaleItem(
      name: 'Observable universe diameter', sizeMeters: 8.8e26, wikipediaTitle: 'Observable_universe',
      description: 'The full extent of the universe we can observe - everything whose light has had time to reach us.'),
];
