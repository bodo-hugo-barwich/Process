#
# spec file for package perl-Process-SubProcess
#


Name: perl-Process-SubProcess
Version: 2.0
Release: 20201002git19c8b0a
Summary: Perl Module for Multiprocessing
License: see https://dev.perl.org/licenses/
Group: 		Development/Libraries
Source:         Process-SubProcess.tar.gz

BuildArch:      noarch

BuildRequires:  perl(Test::More)



%description
Running Sub Processes in an easy way while reading STDOUT, STDERR, Exit Code and possible System Errors.
It also implements running multiple Sub Processes simultaneously while keeping all Report and Error Messages and Exit Codes seperate.


%prep
%setup -q -n Process-SubProcess


%build


%install
rm -rf %{buildroot}


rm -rf %{buildroot}

mkdir -p %{buildroot}%{perl_vendorlib}
mkdir -p %{buildroot}%{_docdir}/%{name}

mv README.md %{buildroot}%{_docdir}/%{name}/
mv etc %{buildroot}%{_docdir}/%{name}/
mv t %{buildroot}%{_docdir}/%{name}/tests

rm -f Makefile* *META* MANIFEST* cpanfile .travis*
rm -fR .github
find ./ -type f -name '.gitignore' -exec rm -f {} \;

mv lib/Process %{buildroot}%{perl_vendorlib}/


%clean
rm -rf $RPM_BUILD_ROOT


%files
%doc %{_docdir}/%{name}/README.md
%{perl_vendorlib}/Process
%dir %{_docdir}/%{name}
%{_docdir}/%{name}/etc
%{_docdir}/%{name}/tests
