# Vitis Service

## Build Setup

Make sure that you have MongoDB installed on your local machine before running through the setup below.

```bash

# clone repository
git clone git@github.com:simonfl3tcher/service.vitis.io.git

# install dependencies
cd service.vitis.io.git && bundle install

# copy & update environment
cp .env.example .env && cp .env.example .env.test

# run tests
bin/rspec --format doc

# boot up server
foreman start
```

## Curl Commands

**Public:**

Get the last user (admin use only):
```bash
curl -X GET localhost:5000/users
```

Authenticate with twitter:
```bash
curl -X GET localhost:5000/authenticate
```

**API:**
_Obtain a User ID + JWT token by visiting the authenticate url above in the browser_

Get user `590e1b1b5fb2aae2a10340ae`:
```bash
curl -X GET \
  http://localhost:5000/api/users/590de9505fb2aafcaea97640 \
  -H 'authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE0OTQwODk0OTIsImlhdCI6MTQ5NDA4NTg5MiwiaXNzIjoidml0aXMuaW8iLCJzY29wZXMiOlsiY3JlYXRlX2ZlZWQiLCJ1cGRhdGVfZmVlZCIsImRlbGV0ZV9mZWVkIiwidmlld19mZWVkIl0sInVzZXIiOnsiaWQiOiI1OTBkZTk1MDVmYjJhYWZjYWVhOTc2NDAiLCJ1c2VybmFtZSI6InNpbW9uZmwzdGNoZXIifX0.S5QtSzyxzetX3GuTdbMFztmvv95h9nnaviIVeooH1Uc'
```

Get feed `590cf90c5fb2aa0d60e62043` for user `590e1b1b5fb2aae2a10340ae`:
```bash
curl -X GET \
  http://localhost:5000/api/users/590e1b1b5fb2aae2a10340ae/feeds/590cf90c5fb2aa0d60e62043 \
  -H 'authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE0OTQwNjkwMjAsImlhdCI6MTQ5NDA2NTQyMCwiaXNzIjoidml0aXMuaW8iLCJzY29wZXMiOlsiY3JlYXRlX2ZlZWQiLCJ1cGRhdGVfZmVlZCIsImRlbGV0ZV9mZWVkIiwidmlld19mZWVkIl0sInVzZXIiOnsiaWQiOiI1OTBjZjkwYzVmYjJhYTBkNjBlNjIwNDIiLCJ1c2VybmFtZSI6IlNpbW9uIEZsM3RjaGVyIn19.1Kt8nTNv5kunpy0Ta_k4_bKpyENQ-48-kuhjM_yXtCU'
```

Create a feed for user `590e1b1b5fb2aae2a10340ae`:
```bash
curl -X POST \
  http://localhost:5000/api/users/590e1b1b5fb2aae2a10340ae/feeds \
  -H 'authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE0OTQxMDAyNjcsImlhdCI6MTQ5NDA5NjY2NywiaXNzIjoidml0aXMuaW8iLCJzY29wZXMiOlsiY3JlYXRlX2ZlZWQiLCJ1cGRhdGVfZmVlZCIsImRlbGV0ZV9mZWVkIiwidmlld19mZWVkIl0sInVzZXIiOnsiaWQiOiI1OTBlMWIxYjVmYjJhYWUyYTEwMzQwYWUiLCJ1c2VybmFtZSI6InNpbW9uZmwzdGNoZXIifX0.MB2ANXnDA_3-swWYJrkB5pgm55SSH1SlK05uO_soDsg' \
  -F 'feed[name]=#golang' \
  -F 'feed[type]=search' \
  -F 'feed[search_parameter]=#golang'
```

Update a feed `590cf90c5fb2aa0d60e62042` for user `590daab95fb2aab274234f7e`:

```bash
curl -X PUT \
  http://localhost:5000/api/users/590cf90c5fb2aa0d60e62042/feeds/590daab95fb2aab274234f7e \
  -H 'authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE0OTQwNjkwMjAsImlhdCI6MTQ5NDA2NTQyMCwiaXNzIjoidml0aXMuaW8iLCJzY29wZXMiOlsiY3JlYXRlX2ZlZWQiLCJ1cGRhdGVfZmVlZCIsImRlbGV0ZV9mZWVkIiwidmlld19mZWVkIl0sInVzZXIiOnsiaWQiOiI1OTBjZjkwYzVmYjJhYTBkNjBlNjIwNDIiLCJ1c2VybmFtZSI6IlNpbW9uIEZsM3RjaGVyIn19.1Kt8nTNv5kunpy0Ta_k4_bKpyENQ-48-kuhjM_yXtCU' \
  -F 'feed[name]=#golang' \
  -F 'feed[type]=search' \
  -F 'feed[search_parameter]=#golang'
```

Delete feed `590daab95fb2aab274234f7e` from user `590cf90c5fb2aa0d60e62042`:

```bash
curl -X DELETE \
  http://localhost:5000/api/users/590cf90c5fb2aa0d60e62042/feeds/590daab95fb2aab274234f7e \
  -H 'authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE0OTQwNjkwMjAsImlhdCI6MTQ5NDA2NTQyMCwiaXNzIjoidml0aXMuaW8iLCJzY29wZXMiOlsiY3JlYXRlX2ZlZWQiLCJ1cGRhdGVfZmVlZCIsImRlbGV0ZV9mZWVkIiwidmlld19mZWVkIl0sInVzZXIiOnsiaWQiOiI1OTBjZjkwYzVmYjJhYTBkNjBlNjIwNDIiLCJ1c2VybmFtZSI6IlNpbW9uIEZsM3RjaGVyIn19.1Kt8nTNv5kunpy0Ta_k4_bKpyENQ-48-kuhjM_yXtCU'
```

## The tech

- [X] JSON web token
- [X] JSON API Specification
- [X] MongoDB
- [X] Sinatra
