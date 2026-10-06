if not get_option ('disable-ui')

date_test = executable('test-date-calculator',
  ['test-date-calculator.vala', '../lib/date-calculator.vala'],
  dependencies: [glib, gobject],
)
test('Date calculator', date_test)

if get_option('ui-tests')
date_window_sources = []
foreach source : gnome_calculator_vala_sources
  if source != 'gnome-calculator.vala'
    date_window_sources += '../src/' + source
  endif
endforeach
date_dialog_test = executable('test-date-dialog',
  ['test-date-dialog.vala', date_window_sources, gnome_calculator_resources],
  dependencies: gnome_calculator_deps,
  link_with: [libcalculator, lib_mpfrg],
  include_directories: gnome_calculator_includes,
  vala_args: gnome_calculator_vala_flags,
  c_args: gnome_calculator_c_flags,
)
test('Date dialog', date_dialog_test, env: ['LC_ALL=C', 'LANGUAGE=C'])
endif

# Common
gnome_calculator_tests_deps = [
  gtk,
  gtksourceview,
  gio,
  glib,
  gobject,
  libmath,
  mpc,
  mpfr,
  posix,
  inc_rooth_dep
]

gnome_calculator_tests_includes = [
  include_directories('../lib'),
]

# Tests

test_equation_sources = [
  'test-equation.vala',
]
test_equation = executable('test-equation', test_equation_sources,
  dependencies: gnome_calculator_tests_deps,
  link_with: [libcalculator, lib_mpfrg],
  include_directories: gnome_calculator_tests_includes,
)
test('Equation test', test_equation)

test_currency_sources = [
  'test-currency-providers.vala',
]
test_currency = executable('test-currency-providers', test_currency_sources,
  dependencies: gnome_calculator_tests_deps,
  link_with: [libcalculator, lib_mpfrg],
  include_directories: gnome_calculator_tests_includes,
)
test('Currency test', test_currency)


test_number_sources = [
  'test-number.vala',
]
test_number = executable('test-number', test_number_sources,
  dependencies: gnome_calculator_tests_deps,
  link_with: [libcalculator, lib_mpfrg],
  include_directories: gnome_calculator_tests_includes,
)
test('Number test', test_number)

test_serializer_sources = [
  'test-serializer.vala',
]
test_serializer = executable('test-serializer', test_serializer_sources,
  dependencies: gnome_calculator_tests_deps,
  link_with: [libcalculator, lib_mpfrg],
  include_directories: gnome_calculator_tests_includes,
)
test('Serializer test', test_serializer)

if get_option('ui-tests')
gci_test_deps = [
	gee,
	gtk,
	inc_rooth_dep,
	gcalc_inc_libh_dep,
	gci_inc_libh_dep
]

test_entry_controler_resource_files = files('test-entry-controller.gresource.xml')
test_entry_controler_resources = gnome.compile_resources('test-entry-controller-resources', test_entry_controler_resource_files)

test_entry_controler_sources = [
  'test-gci-entry-controller.vala',
]
test_entry_controler_sources += test_entry_controler_resources

test_entry_controler = executable('test-entry-controller', test_entry_controler_sources,
  dependencies: gci_test_deps,
  link_with: [libgci, libgcalc],
)
test('gci-entry-controller', test_entry_controler)
endif

endif

tests_deps = [
  gio,
  glib,
  gobject,
  libmath,
  mpc,
  mpfr,
  posix,
  gee,
  inc_rooth_dep
]

test_parsing_sources = [
  'gcalc-parsing.vala',
]

test_parsing = executable('gcalc-parsing', test_parsing_sources,
  dependencies:tests_deps,
  link_with: [libgcalc, lib_mpfrg],
)
test('gcalc-parsing', test_parsing)


test_solve_basic_sources = [
  'gcalc-solving-basic.vala',
]

test_solve_basic = executable('gcalc-solve-basic', test_solve_basic_sources,
  dependencies:tests_deps,
  link_with: [libgcalc, lib_mpfrg],
)
test('gcalc-solve-basic', test_solve_basic)
