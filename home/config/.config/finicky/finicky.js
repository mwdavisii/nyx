export default {
  defaultBrowser: "Safari",
  rewrite: [
    {
      // Redirect all urls to use https
      match: (url) => url.protocol === "http:",
      url: (url) => {
        url.protocol = "https:";
        return url;
      }
    },
    {
      // Unwrap Microsoft Safe Links (Teams/Outlook ATP wrapper)
      match: (url) => url.hostname.includes("safelinks.protection.outlook.com") ||
                       url.hostname.includes("teams.cdn.office.net"),
      url: (url) => {
        const wrapped = url.searchParams.get("url");
        if (wrapped) return new URL(wrapped);
        return url;
      }
    },
    {
      // Strip tracking parameters
      match: () => true,
      url: (url) => {
          const removeKeysStartingWith = ["utm_", "uta_"];
          const removeKeys = ["fbclid", "gclid"];

          const params = new URLSearchParams(url.search);
          for (const key of [...params.keys()]) {
              if (removeKeys.includes(key) ||
                  removeKeysStartingWith.some((prefix) => key.startsWith(prefix))) {
                  params.delete(key);
              }
          }
          url.search = params.toString();
          return url;
      },
    }
  ],
  handlers: [
    {
      // AWS and Azure console in Firefox
      match: finicky.matchHostnames(["awsapps.com", "amazonaws.com", "aws.amazon.com", "portal.azure.com"]),
      browser: "Firefox"
    },
    {
      // Azure login flow in Firefox
      match: (url) => url.hostname.includes("login.microsoftonline.com") &&
                       url.pathname.includes("/organizations/") &&
                       url.pathname.includes("/oauth2/"),
      browser: "Firefox"
    },
    {
      // Work and productivity links in Chrome
      match: finicky.matchHostnames([
        "sjcrh.sharepoint.com",
        "sjcrh.atlassian.net",
        "stjude.org",
        "login.microsoft.com",
        "office.com",
        /protection\.outlook\.com/,
        /.*\.atlassian\.com/,
        "github.com",
        "google.com",
        /.*\.google\.com/,
        /.*\.youtube\.com/,
      ]),
      browser: "Google Chrome"
    },
    {
      // Option key held: open in Firefox
      match: () => finicky.getModifierKeys().option,
      browser: "Firefox"
    },
  ]
}
