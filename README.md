# base-notebook

This is a container image intended to make it easy to run Jupyter notebooks with Apache Spark on OpenShift.  You can use it as-is (by adding it to a project), or you can use it as the basis for another image.  In the latter case, you'll probably want to add some notebooks, data, and/or additional packages to the derived image.

## Usage

### As a standalone image

For your convenience, binary image builds are available from Docker Hub.

* Add the image `radanalyticsio/base-notebook` to an OpenShift project
* Set `JUPYTER_NOTEBOOK_PASSWORD` in the pod environment to something you can remember (this step is optional but highly recommended; if you don't do this, you'll need to trawl the logs for an access token for your new notebook)
* Create a route to the pod

### As a base image

* As `nbuser` (uid 1011), add notebooks to `/notebooks` and data to `/data`.
* This process should be easier in the future; stay tuned!

## Credits

This image was initially based on [Graham Dumpleton's images](https://github.com/getwarped/jupyter-stacks), which have some additional functionality (notably s2i support) that we'd like to incorporate in the future.
