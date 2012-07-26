# Provides functionality to test returned repository from repositories and services test

module RepositoryHelper
  WEBYAST_UPDATES_REPO_NAME     = 'SLE11-WebYaST-SP2-Updates'
  WEBYAST_UPDATES_REPO_ALIAS    = 'nu_novell_com:SLE11-WebYaST-SP2-Updates'
  WEBYAST_UPDATES_REPO_URL      = 'https://nu.novell.com/repo/$RCE/SLE11-WebYaST-SP2-Updates/sle-11-x86_64?credentials=NCCcredentials'
  WEBYAST_UPDATES_REPO_ENABLED  = false
  WEBYAST_UPDATES_REPO_GPGCHECK = true
  WEBYAST_UPDATES_REPO_AUTOREF  = true

  def test_webyast(all_repos)
    repos_found = all_repos.select{|repo| repo[:name] == WEBYAST_UPDATES_REPO_NAME}
    assert_equal(1, repos_found.size)

    assert_equal(WEBYAST_UPDATES_REPO_ENABLED,  repos_found[0][:enabled],     "Repository should not be enabled #{repos_found.inspect}")
    assert_equal(WEBYAST_UPDATES_REPO_GPGCHECK, repos_found[0][:gpgcheck],    "Repository should have GPG Check enabled #{repos_found.inspect}")
    assert_equal(WEBYAST_UPDATES_REPO_AUTOREF,  repos_found[0][:autorefresh], "Repository should have Autorefresh enabled #{repos_found.inspect}")

    assert_equal(WEBYAST_UPDATES_REPO_ALIAS, repos_found[0][:alias], "Repository alias #{repos_found.inspect} does not match #{WEBYAST_UPDATES_REPO_ALIAS}")
    assert_equal(WEBYAST_UPDATES_REPO_URL,   repos_found[0][:url],   "Repository URL #{repos_found.inspect} does not match #{WEBYAST_UPDATES_REPO_URL}")
  end
end
