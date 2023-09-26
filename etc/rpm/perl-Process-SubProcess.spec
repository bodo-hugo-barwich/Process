#
# spec file for package perl-Process-SubProcess
#

%define module_name Process::SubProcess
%define distribution Process-SubProcess
%define release_date %(echo '2023-09-23' | cut -d'T' -f1)
%define release_no %(echo %{release_date} | sed -re 's/\-//g')


Name: 		perl-%{distribution}
Version: 	2.1.7
Release: 	%{release_no}%{?dist}
Summary: 	Perl Module for Multiprocessing
License: 	see https://dev.perl.org/licenses/
Group: 		Development/Libraries
URL:      https://metacpan.org/pod/%{module_name}
Source:   %{distribution}-%{version}.tar.gz

BuildArch:      noarch

BuildRequires:  perl >= 0:5.010
BuildRequires:  perl(ExtUtils::MakeMaker)
BuildRequires:  perl(Test::More)
BuildRequires:  perl(Path::Tiny)
BuildRequires:  perl(Getopt::Long::Descriptive)
BuildRequires:  perl(Data::Dump)
BuildRequires:  perl(Capture::Tiny)
BuildRequires:  perl(JSON)
BuildRequires:  perl(YAML)
Requires:       perl(Path::Tiny)
Requires:       perl(Data::Dump)
Requires:       perl(Getopt::Long::Descriptive)
Requires:       perl(JSON)
Requires:       perl(YAML)



%description
Running Sub Processes in an easy way while reading STDOUT, STDERR, Exit Code and possible System Errors.
It also implements running multiple Sub Processes simultaneously while keeping all Report and Error Messages and Exit Codes seperate.


%prep
%setup -q -n %{distribution}-%{version}


%build
perl Makefile.PL INSTALLDIRS=vendor INSTALLPRIVLIB=%{perl_vendorlib}
make %{?_smp_mflags}


%install
rm -rf $RPM_BUILD_ROOT

make pure_install PERL_INSTALL_ROOT=$RPM_BUILD_ROOT

rm -f .travis*
rm -fR .github scripts
find $RPM_BUILD_ROOT -type f -name '.gitignore' -exec rm -f {} \;
find $RPM_BUILD_ROOT -type f -name .packlist -exec rm -f {} \;
rm -fR docs/src

mkdir -p %{buildroot}%{perl_vendorlib}
mkdir -p %{buildroot}%{_docdir}

mv docs %{buildroot}%{_docdir}/%{name}
mv README.md cpanfile %{buildroot}%{_docdir}/%{name}/
mv t %{buildroot}%{_docdir}/%{name}/tests

%{_fixperms} $RPM_BUILD_ROOT/*


%check
make test


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc %{_docdir}/%{name}/README.md
%doc %{_docdir}/%{name}/Process.jpg
%doc %{_docdir}/%{name}/cpanfile
%{_bindir}/*
%{perl_vendorlib}/*
%dir %{_docdir}/%{name}
%{_docdir}/%{name}/tests
%{_mandir}/man1/*
%{_mandir}/man3/*
