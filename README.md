## Temporal

This configuration provides a straightforward method for deploying Temporal with SQLite persistence on fly.io. Additionally, Litestream is incorporated to enable streaming replication.

### How to Deploy

1. Clone this repo
2. Create .envrc file in the root folder with these environment variables

```
REPLICA_URL=s3://your-bucket-name/temporal_data
AWS_ACCESS_KEY_ID=your-aws-access-key-id
AWS_SECRET_ACCESS_KEY=your-aws-secret-access-key
SKIP_DEFAULT_NAMESPACE_CREATION=false
SKIP_ADD_CUSTOM_SEARCH_ATTRIBUTES=false
```

3. Import env to fly `cat .envrc | fly secrets import`
4. Run `fly launch --no-deploy`
5. Run `fly deploy --ha=false`
6. You can forward the Temporal frontend port to your local machine using fly proxy

```
fly proxy 7233
```

7. That's it
