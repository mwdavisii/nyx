export default {
  defaultBrowser: "Safari",
  rewrite: [
    {
      // Redirect all urls to use https
      match: ({ url }) => url.protocol === "http",
      url: { protocol: "https" }
    },
    {
      match: () => true,
      url: ({url}) => {
          const removeKeysStartingWith = ["utm_", "uta_"];
          const removeKeys = ["fbclid", "gclid"];

          const search = url.search
              .split("&")
              .map((parameter) => parameter.split("="))
              .filter(([key]) => !removeKeysStartingWith.some((startingWith) => key.startsWith(startingWith)))
              .filter(([key]) => !removeKeys.some((removeKey) => key === removeKey));

          return {
              protocol: url.protocol,
              host: url.host,
              pathname: url.pathname,
              search: search.map((parameter) => parameter.join("=")).join("&"),
          };
      },
    }
  ],
  handlers: [
    {
      // Open google.com and *.google.com urls in Google Chrome
      match: [
        finicky.matchHostnames(["awsapps.com", "amazonaws.com", "aws.amazon.com", "portal.azure.com"]),
      ],
      browser: "Firefox"
    },
    // catch azure login
    //https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize
    {
      match: [
        ({
          url
        }) => url.host.includes("login.microsoftonline.com") && url.pathname.includes("/organizations/") && url.pathname.includes("/oauth2/"),
      ],
      browser: "Firefox"
    },
    {
      //sjch links
      match: [
        finicky.matchHostnames(
          [
            "sjcrh.sharepoint.com",
            "sjch.atlassian.net",
            "stjude.org",
            "login.microsoft.com",
            "office.com",
            "protection.outlook.com*atlassian.com",
            "github.com",
            "google.com",
            "*.google.com",
            "*.youtube.com",
          ]
        ),
      ],
      browser: "Google Chrome"
    },
    {
      // Open links in Safari when the option key is pressed
      // Valid keys are: shift, option, command, control, capsLock, and function.
      // Please note that control usually opens a tooltip menu instead of visiting a link
      match: () => finicky.getKeys().option,
      browser: "Firefox"
    },
  ]
}
