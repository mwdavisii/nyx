module.exports = {
    defaultBrowser: "Safari",
    rewrite: [
      {
        // Redirect all urls to use https
        match: ({ url }) => url.protocol === "http",
        url: { protocol: "https" }
      }
    ],
    rewrite: [{
      match: () => true, // Execute rewrite on all incoming urls to make this example easier to understand
      url: ({url}) => {
          const removeKeysStartingWith = ["utm_", "uta_"]; // Remove all query parameters beginning with these strings
          const removeKeys = ["fbclid", "gclid"]; // Remove all query parameters matching these keys
  
          const search = url.search
              .split("&")
              .map((parameter) => parameter.split("="))
              .filter(([key]) => !removeKeysStartingWith.some((startingWith) => key.startsWith(startingWith)))
              .filter(([key]) => !removeKeys.some((removeKey) => key === removeKey));
  
          return {
              ...url,
              search: search.map((parameter) => parameter.join("=")).join("&"),
          };
      },
  }],
    handlers: [
      {
        // Open google.com and *.google.com urls in Google Chrome
        match: [
          "aws.amazon.com*", // 
          finicky.matchDomains(/.*\.aws.amazon.com/),
          finicky.matchDomains(/.*\.amazonaws.com/),
          finicky.matchDomains(/.*\.awsapps.com/),
  
        ],
        browser: "Firefox"
      },
      {
        // Open google.com and *.google.com urls in Google Chrome
        match: [
          "miro.com/*", // match google.com urls
          "*.miro.com/*", // match google.com subdomains
          "*github.com*", //
          "*safelinks.protection.outlook.com*atlassian.com*", //jira links in email
          "samlsp.private.zscaler.com*",
          "identity.getpostman.com*",
        ],
        browser: "Google Chrome"
      },
      {
        //sjch links
        match: [
          finicky.matchDomains(/.*sjcrh.sharepoint.com/),
          finicky.matchDomains(/.*sjch.atlassian.net/),
          finicky.matchDomains(/.*stjude.org/),
          finicky.matchDomains(/login.microsoft.com/),
          finicky.matchDomains(/.*\sjcrh-my*/),
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
      {
        // Open google.com and *.google.com urls in Google Chrome
        match: [
          "https://nam11.safelinks.protection.outlook.com/?url=*meet.google.com*", //Safelinks to google meet
          "google.com*", // match google.com urls
          "*.google.com/*", // match google.com subdomains
          "meet.google.com*"
        ],
        browser: "Google Chrome"
      }
    ]
  };
  
