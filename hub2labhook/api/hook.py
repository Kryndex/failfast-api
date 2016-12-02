from flask import jsonify, request, Blueprint, current_app
from hub2labhook.githubevent import GithubEvent
from hub2labhook.gitlabclient import GitlabClient
from hub2labhook.githubclient import GithubClient
from hub2labhook.api.app import getvalues
from hub2labhook.exception import (Hub2LabException,
                                   InvalidUsage,
                                   InvalidParams,
                                   UnauthorizedAccess,
                                   Unsupported)


hook_app = Blueprint('registry', __name__,)


@hook_app.before_request
def pre_request_logging():
    jsonbody = request.get_json(force=True, silent=True)
    values = request.values.to_dict()
    if jsonbody:
        values.update(jsonbody)

    current_app.logger.info("request", extra={
        "remote_addr": request.remote_addr,
        "http_method": request.method,
        "original_url": request.url,
        "path": request.path,
        "data":  values,
        "headers": dict(request.headers.to_list())})


@hook_app.errorhandler(Unsupported)
@hook_app.errorhandler(UnauthorizedAccess)
@hook_app.errorhandler(Hub2LabException)
@hook_app.errorhandler(InvalidUsage)
@hook_app.errorhandler(InvalidParams)
def render_error(error):
    response = jsonify({"error": error.to_dict()})
    response.status_code = error.status_code
    return response


@hook_app.route("/test_error")
def test_error():
    raise InvalidUsage("error message", {"path": request.path})


@hook_app.route("/api/v1/github_event", methods=['POST'], strict_slashes=False)
def github_event():
    params = getvalues()
    gevent = GithubEvent(params, request.headers)
    gitlabclient = GitlabClient()
    return jsonify(gitlabclient.trigger_pipeline(gevent))


@hook_app.route("/api/v1/github_status", methods=['POST'], strict_slashes=False)
def github_status():
    params = getvalues()
    githubclient = GithubClient(installation_id=params['installation_id'])
    delay = params.get('delay', 0)
    return jsonify(githubclient.update_github_status(params['gitlab_project_id'],
                                                     params['gitlab_build_id'],
                                                     params['github_repo'],
                                                     delay))
