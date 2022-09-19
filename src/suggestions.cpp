#include <iostream>
#include <vector>

signed main() {
  // edit distance
  // returns the nearest argument

  std::string arg; // the argument comes from baxup.sh
  std::vector<std::string> defaults{
      "debug",  "root",   "keep",    "create",   "setup",   "verbose",
      "log",    "show",   "startup", "set-path", "history", "variable",
      "config", "target", "version", "add",      "app"};
  std::vector<int> difference(defaults.size(), 0);
}