#include <iostream>
#include <vector>

static std::string suggest_similar() {
  // edit distance
  // returns the nearest argument

  std::string arg; // the argument comes from baxup.sh
  std::vector<std::string> defaults{
      "debug",   "root",     "keep",   "create",  "setup",
      "verbose", "log",      "show",   "startup", "set-path",
      "history", "variable", "config", "target",  "version",
      "add",     "app",      "freeze", "restore"};
  std::vector<int> difference(defaults.size(), 0);
  return arg;
}